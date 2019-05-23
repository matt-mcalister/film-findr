module PlexAPI
  @@base_url = "http://127.0.0.1:32400"
  @@token = "EJMAqACEwzswyYszGpsb"
  @@options = {
    headers: {
      "Accept" => "application/json",
      "X-Plex-Token" => @@token
    }
  }
  def self.base_url
    @@base_url
  end

  def self.token
    @@token
  end

  def self.options
    @@options
  end

  def self.open_plex
    `open ~/../../Applications/Plex\\ Media\\ Server.app/`
  end


  @@rescued = false
  def self.get(route)
    begin
      r = HTTParty.get("#{self.base_url}#{route}", self.options)
    rescue Errno::ECONNREFUSED
      if !@@rescued
        @@rescued = true
        self.open_plex
        puts "opened plex"
        sleep 1

        r = self.get(route)
      end
    end
    @@rescued = false
    r
  end


  def self.image(thumb)
    PlexAPI.get(thumb)
  end

  def self.get_seasons(id)
    seasons = {}
    if id.nil?
      return seasons
    end
    r = PlexAPI.get("/library/metadata/#{id}/children")
    if r && r.parsed_response["MediaContainer"]["Metadata"]
      r.parsed_response["MediaContainer"]["Metadata"].each do |season|
        seasons[season["index"]] ||= {}
        season_r = PlexAPI.get(season["key"])
        if season_r && season_r.parsed_response["MediaContainer"]["Metadata"]
          season_r.parsed_response["MediaContainer"]["Metadata"].each do |episode|
            seasons[season["index"]][episode["index"]] = episode
          end
        end
      end
    end
    seasons
  end

  def self.get_seasons_with_torrents(tvdb_id:, plex_id:)
    plex_seasons = TVDBQuery.get_seasons(tvdb_id: tvdb_id, plex_id: plex_id)
    imdbId = TVDBQuery.get_imdb_id(tvdb_id)
    torrent_seasons = Rarbg::Search.get_torrents_by_id(imdbId)
    torrent_seasons.keys.each do |season| # season is a string
      torrent_seasons[season].keys.each do |episode| # episode is a string
        if !plex_seasons[season.to_i].nil? && !plex_seasons[season.to_i][episode.to_i].nil?
          plex_seasons[season.to_i][episode.to_i]["torrent_info"] = torrent_seasons[season][episode]
        elsif episode == "full season"
          plex_seasons[season.to_i]["full_season"] = {}
          plex_seasons[season.to_i]["full_season"]["torrent_info"] = torrent_seasons[season][episode]
        end
      end
    end
    plex_seasons
  end

  class Query

    attr_accessor :response, :results, :torrents
    attr_reader :term, :formatted_search, :type, :subtype

    def initialize(term, type)
      @term = term
      @formatted_search = term.gsub(" ", "%20")
      case type
      when :tv
        @type = 4
        @subtype = 2
      when :film
        @type = 3
        @subtype = 1
      end
    end

    def search
      self.response = PlexAPI.get("/library/sections/#{self.type}/search?type=#{self.subtype}&query=#{self.formatted_search}")
      if self.response.parsed_response["Response"] == "False" || self.response.parsed_response["MediaContainer"]["Metadata"].nil?
        self.results = []
      else
        self.results = self.response.parsed_response["MediaContainer"]["Metadata"]
      end
    end

    def search_with_torrents
      self.search
      if self.type == 4 #tv
        self.torrents = TVDBQuery.search_by_name(self.term)
        self.torrents.reject! do |show|
          self.results.any? do |s|
            if s["title"] == show["seriesName"] && s["year"] == show["firstAired"].to_i
              s["tvdb_content"] = show
            else
              false
            end
          end
        end
      else
        self.torrents = YtsAPI.search(self.term)
        self.torrents.reject! {|movie| self.results.any? {|m| m["title"] == movie["title"] && m["year"] == movie["year"]} }
      end
    end

  end
end

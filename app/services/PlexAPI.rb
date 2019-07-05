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

  def self.get_all
    r = self.get("/library/all")
    if r && r.parsed_response["MediaContainer"]["Metadata"]
      items = r.parsed_response["MediaContainer"]["Metadata"].map {|plex_item| PlexAPI::Item.new(plex_item)}
      PlexAPI::Item.threads.map(&:join)
      items
    else
      []
    end
  end

  def self.find_by_imdb_id(imdb_id)
    self.get_all.find {|item| item.guid_exists? && item.guid.include?(imdb_id)}
  end

  def self.find_by_tvdb_id(tvdb_id)
    self.get_all.find {|item| item.guid_exists? && item.guid.include?(tvdb_id.to_s)}
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

  def self.get_seasons_with_torrents(tvdb_id:, plex_id: nil)
    if plex_id.nil?
      item = self.find_by_tvdb_id(tvdb_id)
      plex_id = item && item.ratingKey
    end
    threads = []
    plex_seasons = {}
    torrent_seasons = {}
    threads << Thread.new { plex_seasons = TVDBQuery.get_seasons(tvdb_id: tvdb_id, plex_id: plex_id) }
    threads << Thread.new { torrent_seasons = TorFinder::Tv.search(tvdb_id) }
    threads.map(&:join)
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
    QBitAPI::Torrent.all.each do |tor|
      if tor.category["type"].include?("tv") && tor.category["tvdbID"] == tvdb_id.to_i
        episode = tor.category["episode"]
        plex_seasons[tor.category["season"].to_i][episode]["downloadInProgress"] = true
      end
    end
    plex_seasons
  end


  class Item
    @@threads = []
    def self.threads
      @@threads
    end

    attr_accessor(:ratingKey,
                  :key,
                  :librarySectionTitle,
                  :librarySectionID,
                  :librarySectionKey,
                  :studio,
                  :type,
                  :title,
                  :titleSort,
                  :summary,
                  :rating,
                  :viewCount,
                  :lastViewedAt,
                  :year,
                  :tagline,
                  :thumb,
                  :art,
                  :duration,
                  :originallyAvailableAt,
                  :addedAt,
                  :updatedAt,
                  :chapterSource,
                  :Genre,
                  :Director,
                  :Writer,
                  :Country,
                  :Role,
                  :contentRating,
                  :audienceRating,
                  :audienceRatingImage,
                  :ratingImage,
                  :Collection,
                  :primaryExtraKey,
                  :index,
                  :banner,
                  :theme,
                  :leafCount,
                  :viewedLeafCount,
                  :childCount,
                  :parentRatingKey,
                  :parentKey,
                  :parentTitle,
                  :parentIndex,
                  :parentThumb,
                  :parentTheme,
                  :grandparentRatingKey,
                  :grandparentKey,
                  :grandparentTitle,
                  :viewOffset,
                  :grandparentThumb,
                  :grandparentArt,
                  :grandparentTheme,
                  :subtype,
                  :maxYear,
                  :minYear,
                  :originalTitle,
                  :guid,
                  :Media,
                  :Similar,
                  :Field,
                  :Producer,
                  :got_meta_data)

    def initialize(plex_hash)
      plex_hash.each do |key,value|
        self.send("#{key}=", value)
      end
      @got_meta_data = false
      @@threads << Thread.new { get_metadata }
    end

    def guid_exists?
      guid || get_metadata.guid
    end

    def get_metadata
      r = PlexAPI.get(key.split("/children").first)
      if r && r.parsed_response["MediaContainer"]["Metadata"]
        r.parsed_response["MediaContainer"]["Metadata"].first.each do |key,value|
          if key == "guid" && self.respond_to?(key)
            self.send("#{key}=", value)
          end
        end
        @got_meta_data = true
      end
      self
    end

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
          self.results.any? do |plex_s|
            if plex_s["title"] == show["seriesName"] && plex_s["year"] == show["firstAired"].to_i
              plex_s["tvdb_content"] = show
              true
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

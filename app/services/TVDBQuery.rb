class TVDBQuery

  @@token = ""
  BASE_URL = "https://api.thetvdb.com"

  def self.token
    @@token
  end

  def self.options
    {
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{self.token}"
        }
      }
  end

  def self.assign_token
    r = HTTParty.post(BASE_URL + "/login", {
      body: {
        apikey: ENV["TVDB_APIKEY"],
        userkey: ENV["TVDB_USERKEY"],
        username: ENV["TVDB_USERNAME"]
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
      })
      if r.parsed_response["token"]
        @@token = r.parsed_response["token"]
      else
        @counter ||= 0
        if @counter < 5
          @counter += 1
          puts "trying again: #{@counter}"
          self.assign_token
        end
      end
  end

  def self.search_by_name(name)
    if self.token == ""
      self.assign_token
    end
    r = HTTParty.get(BASE_URL + "/search/series?name=#{name.gsub(" ", "%20")}", self.options)
    if r.parsed_response["data"]
      threads = []
      results = r.parsed_response["data"].map do |show|
        threads << Thread.new {
          posters = HTTParty.get(BASE_URL + "/series/#{show["id"]}/images/query?keyType=poster", self.options).parsed_response["data"]
          if posters.nil?
            show["image_url"] = "http://www.reelviews.net/resources/img/default_poster.jpg"
          else
            show["image_url"] = "https://www.thetvdb.com/banners/#{posters.last["fileName"]}"
          end
        }
        show
      end
      threads.map(&:join)
      results.uniq
    else
      []
    end
  end

  def self.get_seasons(tvdb_id:, plex_id:)
    plex_seasons = PlexAPI.get_seasons(plex_id)
    if self.token == ""
      self.assign_token
    end
    seasons = {}
    threads = []
    r = HTTParty.get(BASE_URL + "/series/#{tvdb_id}/episodes", self.options)
    r.parsed_response["data"].each do |episode|
      seasons[episode["airedSeason"]] ||= {}
      seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]] = episode
      seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]]["in_plex"] = !!(plex_seasons[episode["airedSeason"]] && plex_seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]])
    end
    next_page = r.parsed_response["links"]["next"]
    last_page = r.parsed_response["links"]["last"]
    unless next_page.nil?
      (next_page..last_page).each do |page|
        threads << Thread.new {
          r = HTTParty.get(BASE_URL + "/series/#{tvdb_id}/episodes?page=#{page}", self.options)
          r.parsed_response["data"].each do |episode|
            seasons[episode["airedSeason"]] ||= {}
            seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]] = episode
            seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]]["in_plex"] = !!(plex_seasons[episode["airedSeason"]] && plex_seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]])
          end
        }
      end
    end
    threads.map(&:join)
    seasons
  end

  def self.get_show_by_id(tvdb_id)
    if self.token == ""
      self.assign_token
    end
    r = HTTParty.get(BASE_URL + "/series/#{tvdb_id}", self.options)
    r.parsed_response["data"]
  end

  def self.num_seasons(tvdb_id)
    if self.token == ""
      self.assign_token
    end
    r = HTTParty.get(BASE_URL + "/series/#{tvdb_id}/episodes/summary", self.options)
    r.response.code == "200" && r.parsed_response["data"]["airedSeasons"] ? r.parsed_response["data"]["airedSeasons"].max : nil
  end

  def self.get_imdb_id(tvdb_id)
    r = self.get_show_by_id(tvdb_id)
    r && r["imdbId"].gsub("tt","")
  end



end

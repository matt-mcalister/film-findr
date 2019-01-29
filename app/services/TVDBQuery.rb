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
      end
  end

  def self.search_by_name(name)
    if self.token == ""
      self.assign_token
    end
    r = HTTParty.get(BASE_URL + "/search/series?name=#{name.gsub(" ", "%20")}", self.options)
    if r.parsed_response["data"]
      r.parsed_response["data"].map do |show|
        posters = HTTParty.get(BASE_URL + "/series/#{show["id"]}/images/query?keyType=poster", self.options).parsed_response["data"]
        if posters.nil?
          show["image_url"] = "http://www.reelviews.net/resources/img/default_poster.jpg"
        else
          show["image_url"] = "https://www.thetvdb.com/banners/#{posters.last["fileName"]}"
        end
        show
      end
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
    r = HTTParty.get(BASE_URL + "/series/#{tvdb_id}/episodes", self.options)
    r.parsed_response["data"].each do |episode|
      seasons[episode["airedSeason"]] ||= {}
      seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]] = episode
      seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]]["in_plex"] = !!(plex_seasons[episode["airedSeason"]] && plex_seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]])
    end
    while r.parsed_response["links"]["next"]
      r.parsed_response["data"].each do |episode|
        seasons[episode["airedSeason"]] ||= {}
        seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]] = episode
        seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]]["in_plex"] = !!(plex_seasons[episode["airedSeason"]] && plex_seasons[episode["airedSeason"]][episode["airedEpisodeNumber"]])
      end
      r = HTTParty.get(BASE_URL + "/search/series/#{tvdb_id}/episodes?page=#{r.parsed_response["links"]["next"]}", self.options)
    end
    seasons
  end



end

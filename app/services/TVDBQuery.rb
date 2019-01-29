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
        show["image_url"] = posters.length > 0 ? "https://www.thetvdb.com/banners/#{posters.last["fileName"]}" : "http://www.reelviews.net/resources/img/default_poster.jpg"
        show
      end
    else
      []
    end
  end



end

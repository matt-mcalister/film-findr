class TVDBQuery

  @@token = ""
  BASE_URL = "https://api.thetvdb.com"

  def self.token
    @@token
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

  def self.find_by_name(name)
    r = HTTParty.get(BASE_URL + "/search/series?name=#{name.gsub(" ", "%20")}")
  end




  attr_accessor :response, :results, :seasons
  attr_reader :term, :formatted_term, :imdbID

  def initialize(term: "", imdbID: "")
    @term = term
    @formatted_term = term.gsub(" ", "%20")
    @imdbID = imdbID
  end

  def search
    if self.term != ""
      self.response = HTTParty.get("http://www.omdbapi.com/?type=series&s=#{formatted_term}&apikey=#{ENV["OMDB_API_KEY"]}")
      if self.response.parsed_response["Response"] == "False"
        self.results = []
      else
        self.results = self.response.parsed_response["Search"]
      end
    else
      "CANNOT SEARCH EMPTY STRING"
    end
  end

  def get_seasons
    if self.imdbID != ""
      self.seasons = {}
      seasonCount = 1
      self.response = HTTParty.get("http://www.omdbapi.com/?type=series&i=#{imdbID}&apikey=#{ENV["OMDB_API_KEY"]}&season=#{seasonCount}")
      self.seasons[seasonCount] = self.response.parsed_response["Episodes"].map {|episode| {episode["Episode"].to_i => episode} }
    end
  end


end

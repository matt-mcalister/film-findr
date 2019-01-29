class OMDBQuery
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

class OMDBQuery
  attr_accessor :response, :results
  attr_reader :search, :formatted_search

  def initialize(search)
    @search = search
    @formatted_search = search.gsub(" ", "%20")
  end

  def search
    self.response = HTTParty.get("http://www.omdbapi.com/?type=series&s=#{formatted_search}&apikey=#{ENV["OMDB_API_KEY"]}")
    if self.response.parsed_response["Response"] == "False"
      self.results = []
    else
      self.results = self.response.parsed_response["Search"]
    end
  end


end

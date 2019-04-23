class OMDBQuery
  attr_accessor :response, :results
  attr_reader :term, :formatted_term

  def initialize(term: "")
    @term = term
    @formatted_term = term.gsub(" ", "%20")
  end

  def search
    if self.term != ""
      self.response = HTTParty.get("http://www.omdbapi.com/?type=movie&s=#{formatted_term}&apikey=#{ENV["OMDB_API_KEY"]}")
      if self.response.parsed_response["Response"] == "False"
        self.results = []
      else
        self.results = self.response.parsed_response["Search"]
      end
    else
      "CANNOT SEARCH EMPTY STRING"
    end
  end


end

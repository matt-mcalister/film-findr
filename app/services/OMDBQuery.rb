class OMDBQuery

  def self.search(term)
    if term != ""
      formatted_term = term.gsub(" ", "%20")
      response = HTTParty.get("http://www.omdbapi.com/?type=movie&s=#{formatted_term}&apikey=#{ENV["OMDB_API_KEY"]}")
      if response.parsed_response["Response"] == "False"
        results = []
      else
        results = response.parsed_response["Search"]
      end
    else
      results = []
    end
    results
  end


end

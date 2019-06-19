class OMDBQuery

  def self.search(term)
    if term != ""
      formatted_term = term.gsub(" ", "%20")
      response = HTTParty.get("http://www.omdbapi.com/?type=movie&s=#{formatted_term}&apikey=#{ENV["OMDB_API_KEY"]}")
      if response.parsed_response["Response"] == "False"
        results = []
      else
        results = response.parsed_response["Search"].uniq
      end
    else
      results = []
    end
    results
  end

  def self.find_by_imdb_id(imdbID)
    response = HTTParty.get("http://www.omdbapi.com/?type=movie&i=#{imdbID}&apikey=#{ENV["OMDB_API_KEY"]}")
    if response.parsed_response["Response"] == "false"
      result = {}
    else
      result = response.parsed_response
    end
    result
  end


end

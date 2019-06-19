class YtsAPI

  def self.search(term)
    if !NordVPN.active?
      NordVPN.restart
    end
    response = HTTParty.get("https://yts.am/api/v2/list_movies.json?limit=50&query_term=#{term}")
    if response && response["data"]["movies"]
      response["data"]["movies"].uniq
    else
      []
    end
  end

  def self.best_tor_by_imdb_id(imdb_id)
    tor_results = self.search(imdb_id).first
    if tor_results.nil?
      return {"720p" => nil, "1080p" => nil}
    end
    formatted_results = {
      "720p" => [],
      "1080p" => []
    }
    tor_results["torrents"].each_with_object(formatted_results) do |tor, hash|
      tor["source"] = "YTS"
      hash[tor["quality"]] << tor if hash[tor["quality"]]
    end
    formatted_results.keys.each do |key|
      formatted_results[key] = formatted_results[key].max_by {|tor| tor["seeds"]}
    end
    formatted_results
  end

end

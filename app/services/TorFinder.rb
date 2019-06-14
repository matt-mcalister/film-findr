module TorFinder

  class Movie
    def self.search(imdb_id)
      threads = []
      yts_results = {
        "720p" => nil,
        "1080p" => nil,
      }
      rarbg_results = {
        "720p" => nil,
        "1080p" => nil,
        "UHD" => nil,
      }
      threads << Thread.new { yts_results = YtsAPI.best_tor_by_imdb_id(imdb_id) }
      threads << Thread.new { rarbg_results = Rarbg::Search.movie_search(imdb_id) }
      threads.map(&:join)
      results = {
        "720p" => nil,
        "1080p" => nil,
        "UHD" => nil,
      }
      results.keys.each do |key|
        tor = nil
        if yts_results[key] && rarbg_results[key]
          tor = yts_results[key]["seeds"] > rarbg_results[key]["seeders"] ? yts_results[key] : rarbg_results[key]
        else
          tor = rarbg_results[key] #which is either something, or nil (in either case, it can't be yts_results[key])
        end
        results[key] = tor
      end
      results
    end
  end

end

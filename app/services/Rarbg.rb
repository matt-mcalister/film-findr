module Rarbg


  class Search
    @@query = RARBG::API.new
    @@categories = RARBG::CATEGORIES

    def self.query
      @@query
    end

    def self.categories
      @@categories
    end

    def self.movie_search(imdb_id)
      if !NordVPN.active?
        NordVPN.restart
      end
      tor_results = self.query.search(format: :json_extended, category: [44,45,50,51,52], imdb: imdb_id)
      formatted_results = {
        "720p" => [],
        "1080p" => [],
        "UHD" => []
      }
      tor_results.each_with_object(formatted_results) do |tor, hash|
        tor["source"] = "RARBG"
        case tor["category"]
        when "Movies/x264/1080"
          hash["1080p"] << tor
        when "Movies/x264/720"
          hash["720p"] << tor
        when "Movies/x264/4k", "Movies/x265/4k", "Movs/x265/4k/HDR"
          hash["UHD"] << tor
        end
      end
      formatted_results.keys.each do |key|
        if key == "UHD" && formatted_results[key].length >= 1
          results = formatted_results[key]
          categories = {"Movs/x265/4k/HDR" => 3, "Movies/x265/4k" => 2, "Movies/x264/4k" => 1 }
          top_uhd_torrent = results.first
          results[1..-1].each do |tor|
            if categories[tor["category"]] > categories[top_uhd_torrent["category"]] || (categories[tor["category"]] == categories[top_uhd_torrent["category"]] && tor["seeders"] > top_uhd_torrent["seeders"])
              top_uhd_torrent = tor
            end
          end
          formatted_results[key] = top_uhd_torrent
        else
          formatted_results[key] = formatted_results[key].max_by {|tor| tor["seeders"]}
        end
      end
      formatted_results
    end

    def self.search_720p(imdb_id)
      if !NordVPN.active?
        NordVPN.restart
      end
      results = self.query.search(format: :json_extended, category: [45], imdb: imdb_id)
      results.max_by {|tor| tor["seeders"]}
    end

    def self.search_1080p(imdb_id)
      if !NordVPN.active?
        NordVPN.restart
      end
      results = self.query.search(format: :json_extended, category: [44], imdb: imdb_id)
      results.max_by {|tor| tor["seeders"]}
    end

    def self.search_UHD(imdb_id)
      if !NordVPN.active?
        NordVPN.restart
      end
      results = self.query.search(imdb: imdb_id, category: [50, 51, 52],format: :json_extended)
      categories = {"Movs/x265/4k/HDR" => 3, "Movies/x265/4k" => 2, "Movies/x264/4k" => 1 }
      top_uhd_torrent = results.first
      results[1..-1].each do |tor|
        if categories[tor["category"]] > categories[top_uhd_torrent["category"]] || (categories[tor["category"]] == categories[top_uhd_torrent["category"]] && tor["seeders"] > top_uhd_torrent["seeders"])
          top_uhd_torrent = tor
        end
      end
      top_uhd_torrent
    end

    attr_accessor :imdb_id, :episodes, :formatted_episodes

    def initialize(imdb_id)
      @imdb_id = imdb_id
      @episodes = []
      @formatted_episodes = {}
    end

    def find_episodes(season: nil, episode: nil)
      if !NordVPN.active?
        NordVPN.restart
      end
      rarbg = RARBG::API.new
      season_episode_string = "#{season && 'S' + (season.to_s.length < 10 ? '0' + season.to_s : season.to_s)}#{episode && 'E' + (episode.to_s.length < 10 ? '0' + episode.to_s : episode.to_s)}"
      self.episodes = rarbg.search(imdb: "tt#{self.imdb_id}", category: [41], limit: 100, format: :json_extended, string: season_episode_string).map {|el| Rarbg::Download.new(el)}
    end

    def filter_episodes
      self.episodes.each do |download|
        if download.season.nil?
          season = "0"
          episode = "0"
        else
          season = download.season
          if download.episode.nil?
            episode = "full season"
          else
            episode = download.episode
          end
        end

          self.formatted_episodes[season] ||= {}
          self.formatted_episodes[season][episode] ||= []
          self.formatted_episodes[season][episode] << download
      end

      self.formatted_episodes.keys.each do |season|
        self.formatted_episodes[season].keys.each do |episode|
          self.formatted_episodes[season][episode] = self.formatted_episodes[season][episode].max_by {|ep| ep.seeders}
        end
      end
      self.formatted_episodes
    end

    def self.get_torrents_by_id(imdbid)
      q = self.new(imdbid)
      q.find_episodes
      q.filter_episodes
    end

  end

  class Download
    attr_reader :title, :magnet_url, :season, :episode, :seeders, :leechers

    def initialize(tor_hash)
      @title = tor_hash["title"]
      @seeders = tor_hash["seeders"]
      @leechers = tor_hash["leechers"]
      @magnet_url = tor_hash["download"]
      @season = tor_hash["episode_info"]["seasonnum"]
      @episode = tor_hash["episode_info"]["epnum"] if tor_hash["episode_info"]["epnum"] != "1000000"
    end

  end


end

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

    attr_accessor :imdb_id, :episodes, :formatted_episodes

    def initialize(imdb_id)
      @imdb_id = imdb_id
      @episodes = []
      @formatted_episodes = {}
    end

    def find_episodes(season: nil, episode: nil)
      QBitAPI.open_vpn
      sleep(1)
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

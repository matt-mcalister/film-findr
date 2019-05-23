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
      self.episodes = rarbg.search(imdb: "tt#{self.imdb_id}", category: [41], limit: 100, string: season_episode_string).map {|el| Rarbg::Episode.new(el)}
    end

  end

  class Episode
    attr_reader :filename, :category, :magnet_url, :season, :episode

    def initialize(tor_hash)
      @filename = tor_hash["filename"]
      @category = tor_hash["category"]
      @magnet_url = tor_hash["download"]
      @season, @episode = tor_hash["filename"].scan(/S(\d+)+|E(\d+)+/).map {|arr| arr.compact.first.to_i.to_s}
    end

  end


end

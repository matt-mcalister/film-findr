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

  end


end

module PlexAPI
  @@base_url = "http://127.0.0.1:32400"
  @@token = "EJMAqACEwzswyYszGpsb"
  @@options = {
    headers: {
      "Accept" => "application/json",
      "X-Plex-Token" => @@token
    }
  }
  def self.base_url
    @@base_url
  end

  def self.token
    @@token
  end

  def self.options
    @@options
  end

  def self.image(thumb)
    HTTParty.get("#{@@base_url}#{thumb}", @@options)
  end

  def self.get_seasons(id)
    seasons = {}
    if id.nil?
      return seasons
    end
    r = HTTParty.get("#{@@base_url}/library/metadata/#{id}/children", @@options)
    if r && r.parsed_response["MediaContainer"]["Metadata"]
      r.parsed_response["MediaContainer"]["Metadata"].each do |season|
        seasons[season["index"]] ||= {}
        season_r = HTTParty.get("#{@@base_url}#{season["key"]}", @@options)
        if season_r && season_r.parsed_response["MediaContainer"]["Metadata"]
          season_r.parsed_response["MediaContainer"]["Metadata"].each do |episode|
            seasons[season["index"]][episode["index"]] = episode
          end
        end
      end
    end
    seasons
  end

  class Query

    attr_accessor :response, :results
    attr_reader :search, :formatted_search, :type

    def initialize(search, type)
      @search = search
      @formatted_search = search.gsub(" ", "%20")
      case type
      when :tv
        @type = 2
      when :film
        @type = 1
      end
      self
    end

    def search
      self.response = HTTParty.get("#{PlexAPI.base_url}/library/sections/#{self.type}/search?type=#{self.type}&query=#{self.formatted_search}", PlexAPI.options)
      if self.response.parsed_response["Response"] == "False"
        self.results = []
      else
        self.results = self.response.parsed_response["MediaContainer"]["Metadata"]
      end
    end

  end
end

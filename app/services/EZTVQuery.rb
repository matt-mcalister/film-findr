class EZTVQuery
  attr_accessor :imdb_id, :episodes, :formatted_episodes
  # attr_reader :title, :formatted_title

  def initialize(imdb_id)
    @imdb_id = imdb_id
    @episodes = []
    @formatted_episodes = {}
  end

  def find_episodes
    counter = 1
    url = "https://eztv.io/api/get-torrents?imdb_id=#{self.imdb_id}&page=#{counter}"
    if !NordVPN.active?
      NordVPN.restart
    end
    res = HTTParty.get(url)
    thread_pool = ThreadPool.new(100)
    self.episodes << res.parsed_response["torrents"]
    until self.episodes.length >= res.parsed_response["torrents_count"].to_i || counter == 100
      thread_pool.schedule do
        counter += 1
        begin
          res = HTTParty.get("https://eztv.io/api/get-torrents?imdb_id=#{self.imdb_id}&page=#{counter}")
          self.episodes << res.parsed_response["torrents"]
          self.episodes = self.episodes.flatten
        rescue
          puts "nope: #{counter}"
        end
      end
    end
    thread_pool.run!
    self.episodes
  end

  def filter_episodes
    self.episodes.each do |ep|
      if ep["season"] == "0" && ep["episode"] == "0"
        season, episode = ep["title"].scan(/S(\d+)+|E(\d+)+/).map {|arr| arr.compact.first.to_i.to_s}
      else
        season = ep["season"]
        episode = ep["episode"]
      end
        self.formatted_episodes[season] ||= {}
        self.formatted_episodes[season][episode] ||= []
        self.formatted_episodes[season][episode] << ep
    end

    self.formatted_episodes.keys.each do |season|
      self.formatted_episodes[season].keys.each do |episode|
        self.formatted_episodes[season][episode].reject! {|ep| ep["title"].include?("480p")}
        self.formatted_episodes[season][episode] = self.formatted_episodes[season][episode].max_by {|ep| ep["seeds"] + ep["peers"]}
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

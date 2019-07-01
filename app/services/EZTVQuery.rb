class EZTVQuery
  attr_accessor :imdb_id, :episodes, :formatted_episodes

  def initialize(imdb_id)
    @imdb_id = imdb_id
    @episodes = []
    @formatted_episodes = {}
    @search_complete = false
    @torrents_count = nil
  end

  def assign_thread_pool
    @thread_pool && @thread_pool.kill_all!
    @thread_pool = ThreadPool.new(30)
  end

  def get_episodes_by_page(page)
    if !NordVPN.active?
      NordVPN.restart
    end
    if !@search_complete
      begin
        res = HTTParty.get("https://eztv.io/api/get-torrents?imdb_id=#{self.imdb_id}&page=#{page}")
        puts "#{page}: status code #{res.response.code}"
        puts "#{page}: torrents returned #{res.parsed_response["torrents"].nil? ? 0 : res.parsed_response["torrents"].length}"
        @torrents_count ||= res.parsed_response["torrents_count"]
        if res.response.code == "200" && !res.parsed_response["torrents"].nil?
          self.episodes << res.parsed_response["torrents"]
          self.episodes = self.episodes.flatten
        else
          @search_complete = true
        end
      rescue => e
        puts e
        puts "nope: #{page}"
        @search_complete = true
      end
    else
      @thread_pool.schedule { throw :exit }
    end
  end

  def find_episodes(page: 1)
    assign_thread_pool
    (page..page+30).each do |page|
      if !@search_complete
        @thread_pool.schedule do
          get_episodes_by_page(page)
        end
      end
    end
    puts 'running'
    @thread_pool.run!
    self.episodes = self.episodes.uniq
    if !@search_complete && !found_all?
      find_episodes(page: page+29)
    end
    "done"
  end

  def found_all?
    @torrents_count && self.episodes.length == @torrents_count.to_i
  end

  def filter_episodes
    self.episodes.each do |ep|
      if (ep["season"].nil? && ep["episode"].nil?) || (ep["season"] == "0" && ep["episode"] == "0")
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

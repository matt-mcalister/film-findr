class EZTVQuery
  attr_accessor :imdb_id, :episodes
  # attr_reader :title, :formatted_title

  def initialize(imdb_id)
    @imdb_id = imdb_id
    @episodes = []
  end
  #
  # def get_imdb_id
  #   r = HTTParty.get("http://www.omdbapi.com/?type=series&t=#{formatted_title}&apikey=#{ENV["OMDB_API_KEY"]}")
  #   self.imdb_id = r.parsed_response["imdbID"].gsub("tt", "").to_i
  # end

  def find_episodes
    counter = 1
    url = "https://eztv.io/api/get-torrents?imdb_id=#{self.imdb_id}&page=#{counter}"
    res = HTTParty.get(url)

    while self.episodes.length < res.parsed_response["torrents_count"].to_i
      self.episodes << res.parsed_response["torrents"]
      self.episodes = self.episodes.flatten
      counter += 1
      res = HTTParty.get("https://eztv.io/api/get-torrents?imdb_id=#{self.imdb_id}&page=#{counter}")
    end
    self.episodes
    # each episode:
    # {
    #   "id"=>819872,
    #   "hash"=>"fce1ccaa85bdfcbd25047f79a1037e8340d45ce5",
    #   "filename"=>"Atlanta.S02E11.Crabs.in.a.Barrel.720p.AMZN.WEB-DL.DDP5.1.H.264-NTb[eztv].mkv",
    #   "episode_url"=>"https://eztv.io/ep/819872/atlanta-s02e11-crabs-in-a-barrel-720p-amzn-web-dl-ddp5-1-h-264-ntb/",
    #   "torrent_url"=>"https://zoink.ch/torrent/Atlanta.S02E11.Crabs.in.a.Barrel.720p.AMZN.WEB-DL.DDP5.1.H.264-NTb[eztv].mkv.torrent",
    #   "magnet_url"=>"magnet:?xt=urn:btih:fce1ccaa85bdfcbd25047f79a1037e8340d45ce5&dn=Atlanta.S02E11.Crabs.in.a.Barrel.720p.AMZN.WEB-DL.DDP5.1.H.264-NTb%5Beztv%5D&tr=udp://tracker.coppersurfer.tk:80&tr=udp://glotorrents.pw:6969/announce&tr=udp://tracker.leechers-paradise.org:6969&tr=udp://tracker.opentrackr.org:1337/announce&tr=udp://exodus.desync.com:6969",
    #   "title"=>"Atlanta S02E11 Crabs in a Barrel 720p AMZN WEB-DL DDP5 1 H 264-NTb EZTV",
    #   "imdb_id"=>"4288182",
    #   "season"=>"0",
    #   "episode"=>"0",
    #   "small_screenshot"=>"//ezimg.ch/thumbs/atlanta-s02e11-crabs-in-a-barrel-720p-amzn-web-dl-ddp5-1-h-264-ntb-small.jpg",
    #   "large_screenshot"=>"//ezimg.ch/thumbs/atlanta-s02e11-crabs-in-a-barrel-720p-amzn-web-dl-ddp5-1-h-264-ntb-large.jpg",
    #   "seeds"=>9,
    #   "peers"=>6,
    #   "date_released_unix"=>1526103345,
    #   "size_bytes"=>"1188769570"
    # }
  end

end

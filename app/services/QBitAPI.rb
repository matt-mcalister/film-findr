module QBitAPI
  BASE_URL = "http://localhost:8080/api/v2/torrents"

  # add torrents
    #  must always check first to see if torrent is already present
    #  adds to appropriate file path:
      # ~/Movies/Qbit/PlexPending/movies
      # ~/Movies/Qbit/PlexPending/tv-shows/#{NAME OF SHOW}/#{SEASON NUMBER}
  def self.add_torrent(torrent_hash:, type:, magnet_url:, season: nil, episode: nil, show_title: nil)
    case type
    when "film"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/movies"
    when "tv"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/tv-shows/#{show_title}/#{season}"
    end

    body = "hash=#{torrent_hash}&urls=#{magnet_url}&savepath=#{savepath}"

    HTTParty.post(BASE_URL + "/add",{body: body})

  end

  def self.find_torrent(torrent_hash)
    r = HTTParty.get(BASE_URL + "/properties?hash=#{torrent_hash}")
  end

  # check status of current torrents
    # if any torrent is done, move it to plex
    # if it's a tv show, check if the season folder is now empty and delete the season folder
      # once the season folder has been deleted, if the show folder is empty then delete the show folder

  def self.get_torrents
    r = HTTParty.get("#{BASE_URL}/info")
    r.parsed_response
  end

  class Torrent
    attr_accessor(:addition_date,
        :comment,
        :completion_date,
        :created_by,
        :creation_date,
        :dl_limit,
        :dl_speed,
        :dl_speed_avg,
        :eta,
        :last_seen,
        :nb_connections,
        :nb_connections_limit,
        :peers,
        :peers_total,
        :piece_size,
        :pieces_have,
        :pieces_num,
        :reannounce,
        :save_path,
        :seeding_time,
        :seeds,
        :seeds_total,
        :share_ratio,
        :time_elapsed,
        :total_downloaded,
        :total_downloaded_session,
        :total_size,
        :total_uploaded,
        :total_uploaded_session,
        :total_wasted,
        :up_limit,
        :up_speed,
        :up_speed_avg)

    def initialize(torrent_info = {})
      torrent_info.each do |key, value|
        self.send(("#{key}="), value)
      end
      self
    end


  end


end

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
    QBitAPI::Torrent.new(r.parsed_response)
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

      @@all = []
      attr_accessor(:added_on,
        :amount_left,
        :auto_tmm,
        :category,
        :completed,
        :completion_on,
        :dl_limit,
        :dlspeed,
        :downloaded,
        :downloaded_session,
        :eta,
        :f_l_piece_prio,
        :force_start,
        :hash,
        :last_activity,
        :magnet_uri,
        :max_ratio,
        :max_seeding_time,
        :name,
        :num_complete,
        :num_incomplete,
        :num_leechs,
        :num_seeds,
        :priority,
        :progress,
        :ratio,
        :ratio_limit,
        :save_path,
        :seeding_time_limit,
        :seen_complete,
        :seq_dl,
        :size,
        :state,
        :super_seeding,
        :tags,
        :time_active,
        :total_size,
        :tracker,
        :up_limit,
        :uploaded,
        :uploaded_session,
        :upspeed,
        :media_path,
        )

    def initialize(torrent_info = {})
      torrent_info.each do |key, value|
        self.send(("#{key}="), value)
      end
      if self.save_path.match("/tv-shows/")
        @media_path = "TV\ Shows"
      else
        @media_path = "Movies"
      end
      self
    end

    def file_to_move
      r = HTTParty.get(BASE_URL + "/files?hash=#{hash}")
      r.parsed_response.max_by {|tor| tor["size"]}
    end


    # puts "BEGINNING ADD"
    # queue = Dir["/Users/MattMcAlister/Movies/Bit/auto-added/**/*.mp4"]
    # destination_path = "/Volumes/plexserv/Movies"
    # puts "EXECUTING"
    # queue.each do |original_path|
    #   puts "ORIGINAL PATH: #{original_path}"
    #   file_name = original_path.split("/").last
    #   puts "FILE NAME: #{file_name}"
    #   new_path = "#{destination_path}/#{file_name}"
    #   puts "NEW PATH: #{new_path}"
    #   puts "MOVING"
    #   FileUtils.mv(original_path, new_path)
    #   puts "MOVED"
    #   puts "*********************"
    # end
    # puts "ALL PATHS MOVED"

    def move_to_plex
      destination_path = "/Volumes/plexserv/#{self.media_path}"
      original_path = self.save_path + file_to_move["name"]
      file_name = original_path.split("/").last
      puts "ORIGINAL PATH: #{original_path}"
      puts "FILE NAME: #{file_name}"
      new_path = "#{destination_path}/#{self.save_path.split("/tv-shows/")[1]}#{file_name}"
      puts "NEW PATH: #{new_path}"
        FileUtils.mv(original_path, new_path)
    end

    def self.all
      @@all.empty? ? @@all = QBitAPI.get_torrents.map {|tor| Torrent.new(tor)} : @@all
    end


  end


end

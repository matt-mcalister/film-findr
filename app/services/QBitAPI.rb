module QBitAPI
  BASE_URL = "http://localhost:8080/api/v2/torrents"
  @@rescued = false

  def self.open_qbit
    if !NordVPN.active?
      NordVPN.restart
    end
    `open ~/../../Applications/qbittorrent.app/`
  end

  def self.get(route)
    begin
      r = HTTParty.get(BASE_URL + route)
    rescue Errno::ECONNREFUSED
      if !@@rescued
        @@rescued = true
        self.open_qbit
        sleep 1
        r = self.get(route)
      end
    end
    @@rescued = false
    r
  end

  def self.post(route, options = {})
    begin
      r = HTTParty.post(BASE_URL + route, options)
    rescue Errno::ECONNREFUSED
      if !@@rescued
        @@rescued = true
        self.open_qbit
        sleep 1
        r = self.post(route, options)
      end
    end
    @@rescued = false
    r
  end

  # add torrents
    #  must always check first to see if torrent is already present
    #  adds to appropriate file path:
      # ~/Movies/Qbit/PlexPending/movies
      # ~/Movies/Qbit/PlexPending/tv-shows/#{NAME OF SHOW}/#{SEASON NUMBER}
  def self.add_torrent(torrent_hash:, type:, magnet_url:, title:, isLocal: false, season: nil, episode: nil, show_slug: nil)
    case type
    when "film"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/movies"
    when "tv", "tv - full season"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/tv-shows/#{show_slug}/#{season}"
    when "uhd"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/uhd"
    end

    body = "hash=#{torrent_hash}&urls=#{magnet_url}&savepath=#{savepath}"

    self.post("/add",{body: body})
    Download.create(torrent_hash: torrent_hash, title: title, isLocal: isLocal, mediaType: type, season: season, episode: episode)
  end

  def self.get_torrents
    r = self.get("/info")
    r.parsed_response
  end

  class Torrent

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
        :external_drive
        )

    def initialize(torrent_info = {})
      torrent_info.each do |key, value|
        self.send(("#{key}="), value)
      end
      if self.save_path.match("/tv-shows/")
        @media_path = "TV\ Shows"
        @external_drive = true
      elsif self.save_path.match("/movies/")
        @media_path = "Movies"
        @external_drive = true
      elsif self.save_path.match("/uhd/")
        @external_drive = false
        @media_path = "plex-movies-temp"
      end
      self
    end

    def file_to_move
      r = QBitAPI.get("/files?hash=#{hash}")
      r.parsed_response.max_by {|tor| tor["size"]}
    end


    def delete_torrent
      body = "hashes=#{hash}&deleteFiles=true"
      QBitAPI.post("/delete",{body: body})
      puts "DELETED"
    end

    def move_to_plex
      if external_drive
        destination_path = "/Volumes/plexserv/#{self.media_path}"
      else
        destination_path = "/Users/MattMcAlister/Movies/#{self.media_path}"
      end
      original_path = self.save_path + file_to_move["name"]
      file_name = original_path.split("/").last
      puts "ORIGINAL PATH: #{original_path}"
      puts "FILE NAME: #{file_name}"
      new_path = "#{destination_path}/#{self.save_path.split("/tv-shows/")[1]}#{file_name}"
      puts "NEW PATH: #{new_path}"
      FileUtils.mv(original_path, new_path)
      puts "MOVED"
      delete_torrent
    end

    def self.all
      QBitAPI.get_torrents.map {|tor| Torrent.new(tor)}
    end

    def self.find_by_hash(hash)
      self.all.find {|tor| tor.hash.downcase == hash.downcase}
    end

    def self.ready_to_migrate
      self.all.select {|tor| tor.amount_left == 0}
    end

    def self.migrate_completed_torrents
      thread_pool = ThreadPool.new(50)
      self.ready_to_migrate.each do |tor|
        thread_pool.schedule do
          tor.move_to_plex
        end
      end
      thread_pool.run!
    end

  end


end

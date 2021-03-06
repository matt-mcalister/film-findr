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
  def self.add_torrent(torrent_hash:, type:, magnet_url:, title:, imdbID: nil, tvdbID: nil, isLocal: false, season: nil, episode: nil, show_slug: nil)
    case type
    when "film"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/movies"
    when "tv", "tv - full season"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/tv-shows/#{show_slug}/#{season}"
    when "uhd"
      savepath = "/Users/MattMcAlister/Movies/Qbit/PlexPending/uhd"
    end

    info = {
      type: type,
      title: title,
      imdbID: imdbID,
      tvdbID: tvdbID,
      season: season,
      episode: episode
    }.to_json

    body = "hash=#{torrent_hash}&urls=#{magnet_url}&savepath=#{savepath}&category=#{info}"

    self.post("/add",{body: body})
    TorWatcher.new(torrent_hash: torrent_hash, type: type, isLocal: isLocal)
  end

  def self.get_torrents
    r = self.get("/info")
    r.parsed_response
  end

  def self.find_by_imdb_id(imdbID)
    QBitAPI::Torrent.all.find {|tor| tor.category["imdbID"] == imdbID}
  end

  def self.find_by_tvdb_id(tvdbID)
    QBitAPI::Torrent.all.find {|tor| tor.category["tvdbID"] == tvdbID}
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

    def category
      JSON.parse(@category)
    end

    def handle_srt_files(files)
      if external_drive
        destination_path = "/Volumes/plexserv/#{self.media_path}/#{self.save_path.split("/tv-shows/")[1]}"
      else
        destination_path = "/Users/MattMcAlister/Movies/plex-movies-temp/"
      end
      files.select {|file| file["name"][-4..-1] == ".srt"}.each do  |srt_file|
        original_path = "#{self.save_path}#{srt_file["name"]}"
        new_path = "#{destination_path}#{srt_file["name"].split("/").last}"
        puts "MOVING SUBTITLE TO: #{new_path}"
        begin
          FileUtils.mv(original_path, new_path)
        rescue Errno::ENOENT => e
          FileUtils.makedirs(new_path.split("/")[0...-1].join("/"))
          puts "new folder made"
          FileUtils.mv(original_path, new_path)
        end
      end
    end

    def prepare_files_for_plex
      files = QBitAPI.get("/files?hash=#{hash}").parsed_response
      self.handle_srt_files(files)
      if files.any? {|file| file["name"][-4..-1] == ".mkv"}
        self.handle_mkv_files
      else
        self.move_to_plex
      end
    end

    def handle_mkv_files
      mkv_info = MkvInfo.new(self.save_path + file_to_move["name"])
      if mkv_info.uhd
        self.move_to_plex(isLocal: true)
      else
        self.transcode(size: mkv_info.size)
      end
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

    def transcode(size: 1080)
      resolution = size < 800 ? 720 : 1080
      Transcoder.transcode_from_folder(preset: "Apple #{resolution}p30 Surround", origin_folder: "#{self.save_path}/**/", destination_folder: self.save_path.gsub("/Qbit/PlexPending/tv-shows/", "/HandBroken/TV\ Shows/"))
      delete_torrent
    end

    def move_to_plex(isLocal: false)
      if external_drive && !isLocal
        destination_path = "/Volumes/plexserv/#{self.media_path}"
      else
        destination_path = "/Users/MattMcAlister/Movies/plex-movies-temp"
      end
      original_path = self.save_path + file_to_move["name"]
      file_name = original_path.split("/").last
      puts "ORIGINAL PATH: #{original_path}"
      puts "FILE NAME: #{file_name}"
      new_path = "#{destination_path}/#{self.save_path.split("/tv-shows/")[1]}#{file_name}"
      puts "NEW PATH: #{new_path}"
      begin
        FileUtils.mv(original_path, new_path)
      rescue Errno::ENOENT => e
        FileUtils.makedirs(new_path.split("/")[0...-1].join("/"))
        puts "new folder made"
        FileUtils.mv(original_path, new_path)
      end
      puts "MOVED"
      delete_torrent
    end

    def self.all
      QBitAPI.get_torrents.map {|tor| Torrent.new(tor)}
    end

    def self.find_by_hash(hash)
      self.all.find do |tor|
        tor.hash.downcase == hash.downcase unless hash.nil? || tor.hash.nil?
      end
    end

    def self.ready_to_migrate
      self.all.select {|tor| tor.amount_left == 0}
    end

    def self.migrate_completed_torrents
      thread_pool = ThreadPool.new(50)
      self.ready_to_migrate.each do |tor|
        thread_pool.schedule do
          tor.prepare_files_for_plex
        end
      end
      thread_pool.run!
    end

  end


end

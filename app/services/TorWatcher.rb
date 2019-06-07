class TorWatcher

  attr_reader :torrent_hash, :type, :isLocal

  @@jobs = Queue.new
  @@active_thread = Thread.new { puts "TorWatcher online" }

  def initialize(torrent_hash:, type:, isLocal: false)
    @torrent_hash = torrent_hash
    @type = type
    @isLocal = isLocal
    @@jobs << Proc.new { self.watch_progress }
    if !TorWatcher.active_thread.alive?
      TorWatcher.initiate_thread
    end
  end

  def self.active_thread
    @@active_thread
  end

  def self.initiate_thread
    @@active_thread = Thread.new do
      loop do
        job = @@jobs.pop
        job.call
      end
    end
  end

  def torrent
    QBitAPI::Torrent.find_by_hash(torrent_hash)
  end

  def is_done?
    torrent.amount_left == 0 && torrent.state != "metaDL"
  end


  def delay
    delay_time = torrent.eta / 4

    if delay_time < 30
      30
    elsif delay_time > 1800
      1800
    else
      delay_time
    end
  end

  def watch_progress
    puts "watching that progress"
    sleep(30)
    until is_done?
      puts "NOT DONE, WILL CHECK IN #{delay}"
      sleep(delay)
    end
    puts "TOR DOWNLOAD COMPLETE #{torrent_hash}"
    Thread.new { prepare_files_for_plex }
  end

  def prepare_files_for_plex
    if type != "tv"
      torrent.move_to_plex(isLocal: isLocal)
    else
      torrent.transcode
    end
  end

  def self.queue_tors_in_progress
    QBitAPI::Torrent.all.sort_by {|tor| tor.priority }.each do |tor|
      TorWatcher.new(torrent_hash: tor.hash, type: tor.category)
    end
  end

end

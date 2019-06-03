require Rails.root.join('app/services/ThreadPool.rb')

class TorWatcher

  attr_reader :torrent_hash, :type, :title, :isLocal, :season, :episode, :show_slug, :qbit_path

  @@watchers = ThreadPool.new(1)

  def initialize(torrent_hash:, type:, title:, qbit_path:, isLocal: false, season: nil, episode: nil, show_slug: nil)
    @torrent_hash = torrent_hash
    @type = type
    @title = title
    @isLocal = isLocal
    @season = season
    @episode = episode
    @show_slug = show_slug
    @qbit_path = qbit_path
    @@watchers.schedule do
      self.watch_progress
    end
  end

  def self.watchers
    @@watchers
  end

  def torrent
    QBitAPI::Torrent.find_by_hash(torrent_hash)
  end

  def is_done?
    torrent.amount_left == 0
  end


  def delay
    delay_time = torrent.eta / 2

    if delay_time < 60
      60
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
    puts "TOR COMPLETE #{torrent_hash}"
  end

end

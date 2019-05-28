class NordVPN
  def self.open
    `open ~/../../Applications/NordVPN.app/`
    sleep 1
  end

  def self.pid
    pid = `pgrep NordVPN`.to_i
    if pid == 0
      self.open
      self.pid
    else
      pid
    end
  end

  def self.most_recent_log_file
    Dir["/Users/MattMcAlister/Library/Caches/com.nordvpn.osx/Logs/*.log"].max
  end

  def self.active?
    self.pid # this line ensures that nordvpn is open
    f = File.open(NordVPN.most_recent_log_file)
    f.reverse_each do |log|
      if log.include?("Disconnected")
        return false
      elsif log.include?("Connected to")
        return true
      else
        nil
      end
    end
  end

  def self.restart
    `kill #{NordVPN.pid}`
    self.open
  end
end

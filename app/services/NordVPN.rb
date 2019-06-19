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

  def self.nth_most_recent_log_file(n)
    Dir["/Users/MattMcAlister/Library/Caches/com.nordvpn.osx/Logs/*.log"].sort[n * -1]
  end

  def self.active?(nth_attempt = nil)
    self.pid # this line ensures that nordvpn is open
    if nth_attempt
      f = File.open(NordVPN.nth_most_recent_log_file(nth_attempt))
    else
      f = File.open(NordVPN.most_recent_log_file)
    end
    f.reverse_each do |log|
      if log.include?("Disconnected")
        return false
      elsif log.include?("Connected to")
        return true
      else
        nil
      end
    end
    nth_attempt ||= 1
    if nth_attempt < 5
      nth_attempt += 1
      self.active?(nth_attempt)
    else
      return false
    end
  end

  def self.restart
    `kill #{NordVPN.pid}`
    sleep 0.5
    self.open
    sleep 1
  end
end

class NordVPN
  def self.open 
    `open ~/../../Applications/NordVPN.app/`
    sleep 1
  end

  def self.vpn_pid
    pid = `pgrep NordVPN`.to_i
    if pid == 0
      self.open
      self.vpn_pid
    else
      pid
    end
  end
end

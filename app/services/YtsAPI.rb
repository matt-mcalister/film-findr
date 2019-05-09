class YtsAPI

  def self.search(term)
    QBitAPI.open_vpn
    sleep(1)
    response = HTTParty.get("https://yts.am/api/v2/list_movies.json?quality=1080p&limit=50&query_term=#{term}")
    if response && response["data"]["movies"]
      response["data"]["movies"].uniq
    else
      []
    end
  end

end

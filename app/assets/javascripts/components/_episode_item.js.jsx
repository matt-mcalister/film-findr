const EpisodeItem = ({ episode: { episodeName, filename, airedSeason, airedEpisodeNumber, in_plex, torrent_info, downloadInProgress }, addToPlex }) => {
    const image_url = filename ? ("https://www.thetvdb.com/banners/" + filename) : "https://bigriverequipment.com/wp-content/uploads/2017/10/no-photo-available.png"
    if (!episodeName) {
      return null
    }
    return(
      <div className="item episode">
        <img src={image_url} alt={episodeName} />
        <h4>{airedEpisodeNumber}. {episodeName}</h4>
        {in_plex ? <h6>Currently In Plex</h6> : downloadInProgress ? <h6>Download in progress</h6> : torrent_info ? <button onClick={addToPlex}>Add To Plex</button> : <h6>Download Not Available</h6>}
      </div>
    )
}

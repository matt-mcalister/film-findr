const EpisodeItem = ({ episode: { episodeName, filename, airedSeason, airedEpisodeNumber, in_plex } }) => {

    return(
      <div className="item episode">
        <img src={"https://www.thetvdb.com/banners/" + filename} alt={episodeName} />
        <h4>{airedEpisodeNumber}. {episodeName}</h4>
        {in_plex ? <h6>Currently In Plex</h6> : <button>Add To Plex</button>}
      </div>
    )
}

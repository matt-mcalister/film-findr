const EpisodeItem = ({ episode: { episodeName, filename, firstAired } }) => {

    return(
      <div className="item episode">
        <img src={"https://www.thetvdb.com/banners/" + filename} alt={episodeName} />
        <h4>{episodeName} ({firstAired})</h4>
      </div>
    )
}

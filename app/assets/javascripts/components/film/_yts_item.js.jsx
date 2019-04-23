const YTSItem = (props) => {
  const download = (tor) => {
    fetch("/api/v1/films/download", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        torrent_hash: tor.hash,
        type: "film",
        magnet_url: `magnet:?xt=urn:btih:${tor.hash}&dn=${props.slug}&tr=udp://tracker.openbittorrent.com:80`
      })
    })
  }
    return(
      <div className="item yts">
        <img src={props.medium_cover_image} alt={props.title} />
        <h4>{props.title} ({props.year})</h4>
        <p>Download:</p>
        {props.torrents.map(tor => {
          return <button key={tor.hash} onClick={e => download(tor)}>{tor.quality}</button>
        })}
      </div>
    )
}

class YTSItem extends React.Component {
  download(tor){
    fetch("/api/v1/films/download", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        torrent_hash: tor.hash,
        type: "film",
        magnet_url: `magnet:?xt=urn:btih:${tor.hash}&dn=${this.props.slug}&tr=udp://tracker.openbittorrent.com:80`
      })
    })
  }

  render() {
    return(
      <div className="item yts">
      <img src={this.props.medium_cover_image} alt={this.props.title} />
      <h4>{this.props.title} ({this.props.year})</h4>
      <p>Download:</p>
      {this.props.torrents.map(tor => {
        return <button key={tor.hash} onClick={e => this.download(tor)}>{tor.type} - {tor.quality}</button>
      })}
      </div>
    )
  }
}

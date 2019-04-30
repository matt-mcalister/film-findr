class YTSItem extends React.Component {
  constructor(props){
      super(props)
      this.state = {
        uhd_searched: false,
        uhd_tor: null,
        searching: false,
      }
      this.findUHD = this.findUHD.bind(this)
  }

  findUHD(){
    this.setState({
      searching: true,
      uhd_searched: true,
    })
    fetch("/api/v1/films/4k", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        imdb_id: this.props.imdb_code
      })
    }).then(r => r.json()).then(json => {
        this.setState({
          searching: false,
          uhd_tor: json.torrent
        })
    })
  }

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
    if (this.state.uhd_tor){
      console.log(this.state.uhd_tor);
    }
    return(
      <div className="item yts">
      <img src={this.props.medium_cover_image} alt={this.props.title} />
      <h4>{this.props.title} ({this.props.year})</h4>
      <p>Download:</p>
      {this.props.torrents.map(tor => {
        return <button key={tor.hash} onClick={e => this.download(tor)}>{tor.type} - {tor.quality}</button>
      })}
      {!this.state.uhd_searched ?
        <button onClick={this.findUHD}>Check for 4K</button> :
        this.state.searching ? <p>Searching...</p> :
        !this.state.uhd_tor ? <p>No 4k Torrents Found</p> :
        <button>4k Torrent</button>
      }
      </div>
    )
  }
}

class FilmTors extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      torrents: null,
      loading: true,
      inPlex: false
    }
    this.download = this.download.bind(this)
  }

  componentDidMount(){
    fetch("/api/v1/films/imdb_id", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        imdb_id: this.props.imdbID
      })
    }).then(r => r.json()).then(({torrents, inPlex}) => {
      this.setState({
        torrents,
        inPlex,
        loading: false
      })
    })
  }

  download(tor, resolution){
    let hash;
    if (tor.source === "YTS"){
      hash = tor.hash
    } else {
      hash = tor.download.match(/.+(?=\&dn=)/)[0].replace("magnet:?xt=urn:btih:", "")
    }
    let type = "film"
    if (resolution === "UHD"){
      type = "uhd"
    }
    fetch("/api/v1/films/download", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        imdbID: this.props.imdbID,
        isLocal: false,
        title: this.props.title,
        torrent_hash: tor.hash,
        type: type,
        magnet_url: `magnet:?xt=urn:btih:${hash}`
      })
    })
  }

  render(){
    if (this.state.loading) {
      return <Loading />
    }
    if (this.state.inPlex){
      return <p>Currently in Plex</p>
    }
    let torrents = this.state.torrents || {}
    let foundTorrents = Object.keys(torrents).filter( resolution => {
      return torrents[resolution]
    })
    if (foundTorrents.length > 0){
      return (
        <div>
          {foundTorrents.map(resolution => <DownloadFilm key={resolution} tor={torrents[resolution]} resolution={resolution} download={() => this.download(torrents[resolution], resolution)}/>)}
        </div>
      )
    } else {
      return <p>No Tors Found</p>
    }

  }
}

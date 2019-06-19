class FilmTors extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      torrents: null,
      loading: true,
    }
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
    }).then(r => r.json()).then((torrents) => {
      this.setState({
        torrents,
        loading: false
      })
    })
  }

  render(){
    if (this.state.loading) {
      return <Loading />
    }
    let torrents = this.state.torrents || {}
    console.log(this.state.torrents);
    let foundTorrents = Object.keys(torrents).filter( resolution => {
      return torrents[resolution]
    })
    if (foundTorrents.length > 0){
      return (
        <div>
          {foundTorrents.map(resolution => <DownloadFilm key={resolution} tor={torrents[resolution]} resolution={resolution}/>)}
        </div>
      )
    } else {
      return <p>No Tors Found</p>
    }

  }
}

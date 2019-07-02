class TVTors extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      seasons: {},
      selectedSeason: 0,
      loading: true
    }
    this.selectSeason = this.selectSeason.bind(this)
    this.addToPlex = this.addToPlex.bind(this)
  }

  componentDidMount(){
    fetch("/api/v1/films/get_seasons", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        tvdb_id: this.props.tvdbId
      })
    }).then(r => r.json())
      .then(seasons => {
        const seasonNums = Object.keys(seasons)
        this.setState({
          seasons: seasons,
          selectedSeason: seasonNums[seasonNums.length - 1],
          loading: false
        })
      })
  }


  selectSeason(e){
    this.setState({
      selectedSeason: e.target.value
    })
  }

  addToPlex(episode){
    let torrent_hash = episode.torrent_info.magnet_url.match(/.+(?=\&dn=)/)[0].replace("magnet:?xt=urn:btih:", "")
    const seasons = {...this.state.seasons}
    seasons[this.state.selectedSeason][episode.airedEpisodeNumber].downloadInProgress = true
    this.setState({
      seasons: seasons
    })
    fetch("/api/v1/films/download", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        torrent_hash: torrent_hash,
        type: "tv",
        tvdbID: this.props.tvdbId,
        magnet_url: episode.torrent_info.magnet_url,
        season: episode.airedSeason,
        episode: episode.airedEpisodeNumber,
        show_slug: this.props.slug,
        title: this.props.seriesName,
        isLocal: false,
      })
    })
  }

  render(){
    if (this.state.loading) {
      return <Loading />
    }
    const seasons = Object.keys(this.state.seasons)
    return (
      <div>
      {seasons.length > 0 && <SeasonPicker seasons={Object.keys(this.state.seasons)} selectedSeason={this.state.selectedSeason} selectSeason={this.selectSeason} />}
      {seasons.length > 0 && this.state.seasons[this.state.selectedSeason]["full_season"] && <button onClick={console.log}>Full Season Download Available</button>}
      {this.state.seasons[this.state.selectedSeason] && <EpisodesList episodes={this.state.seasons[this.state.selectedSeason]} addToPlex={this.addToPlex}/>}
      </div>
    )

  }
}

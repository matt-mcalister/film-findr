class SelectedShow extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      seasons: {},
      selectedSeason: 0
    }
    this.selectSeason = this.selectSeason.bind(this)
    this.addToPlex = this.addToPlex.bind(this)
    this.downloadFullSeason = this.downloadFullSeason.bind(this)
  }

  componentDidMount(){
    const plex_id = this.props.selectedShow.ratingKey || null
    fetch("/api/v1/films/get_seasons", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        tvdb_id: this.props.selectedShow.tvdb_content.id,
        plex_id: plex_id
      })
    }).then(r => r.json())
      .then(seasons => {
        const seasonNums = Object.keys(seasons)
        this.setState({
          seasons: seasons,
          selectedSeason: seasonNums[seasonNums.length - 1]
        })
      })
  }

  selectSeason(e){
    this.setState({
      selectedSeason: e.target.value
    })
  }

  addToPlex(episode){
    console.log("EPISODE: ", episode);
    console.log("SHOW: ", this.props.selectedShow);
    // torrent_hash:, type:, magnet_url:, season: nil, episode: nil, show_title: nil
    const seasons = {...this.state.seasons}
    seasons[this.state.selectedSeason][episode.airedEpisodeNumber].in_plex = true
    this.setState({
      seasons: seasons
    })
    fetch("/api/v1/films/download", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        torrent_hash: episode.torrent_info.hash,
        type: "tv",
        magnet_url: episode.torrent_info.magnet_url,
        season: episode.airedSeason,
        episode: episode.airedEpisodeNumber,
        show_title: this.props.selectedShow.tvdb_content.slug,
        isLocal: false,
      })
    })
  }

  downloadFullSeason(){
    console.log("DOWNLOAD FULL SEASON!!!!!!!");
    console.log(this.state.seasons[this.state.selectedSeason]["full_season"]);
  }


  render(){
    const { seriesName, image_url } = this.props.selectedShow.tvdb_content
    const seasons = Object.keys(this.state.seasons)
    return (
      <div id="selected-show">
        <h1>{seriesName}</h1>
        <img src={image_url} alt={seriesName} />
        {seasons.length > 0 && <SeasonPicker seasons={Object.keys(this.state.seasons)} selectedSeason={this.state.selectedSeason} selectSeason={this.selectSeason} />}
        {seasons.length > 0 && this.state.seasons[this.state.selectedSeason]["full_season"] && <button onClick={this.downloadFullSeason}>Full Season Download Available</button>}
        {this.state.seasons[this.state.selectedSeason] && <EpisodesList episodes={this.state.seasons[this.state.selectedSeason]} addToPlex={this.addToPlex}/>}
      </div>
    )
  }
}

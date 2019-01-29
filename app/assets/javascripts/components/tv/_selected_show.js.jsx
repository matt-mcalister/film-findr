class SelectedShow extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      seasons: {},
      selectedSeason: 0
    }
    this.selectSeason = this.selectSeason.bind(this)
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
    console.log(e.target.value);
    this.setState({
      selectedSeason: e.target.value
    })
  }


  render(){
    console.log(this.state);
    const { seriesName, image_url } = this.props.selectedShow.tvdb_content
    const seasons = Object.keys(this.state.seasons)
    return (
      <div id="selected-show">
        <h1>{seriesName}</h1>
        <img src={image_url} alt={seriesName} />
        {seasons.length > 0 && <SeasonPicker seasons={Object.keys(this.state.seasons)} selectedSeason={this.state.selectedSeason} selectSeason={this.selectSeason} />}
        {this.state.seasons[this.state.selectedSeason] && <EpisodesList episodes={this.state.seasons[this.state.selectedSeason]} />}
      </div>
    )
  }
}

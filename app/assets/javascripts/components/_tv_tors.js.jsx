class TVTors extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      seasons: {},
      selectedSeason: 0,
      loading: true
    }
    this.selectSeason = this.selectSeason.bind(this)
  }

  selectSeason(e){
    this.setState({
      selectedSeason: e.target.value
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
      {this.state.seasons[this.state.selectedSeason] && <EpisodesList episodes={this.state.seasons[this.state.selectedSeason]} addToPlex={console.log}/>}
      </div>
    )

  }
}

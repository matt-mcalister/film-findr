class TVMain extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      searchTerm: "",
      plexResults: [],
      tvdbResults: [],
      results_found: false,
      searchMade: false,
      selectedShow: null
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.selectShow = this.selectShow.bind(this)
  }

  handleChange(e) {
    this.setState({
      searchTerm: e.target.value
    })
  }

  handleSubmit(e) {
    e.preventDefault()
    fetch("/api/v1/films/tv", {
      method: "POST",
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        search_term: this.state.searchTerm
      })
    }).then(res => res.json())
      .then((json) => {
        if (json.results_found) {
          const plexResults = json.plex.results || []
          const tvdbResults = json.tvdb.results || []
          this.setState({
            searchMade: true,
            results_found: true,
            tvdbResults: tvdbResults,
            plexResults: plexResults
          })
        } else {
            this.setState({
              searchMade: true,
              results_found: true
            })
        }
      })
  }

  selectShow(show){
    this.setState({
      selectedShow: show
    })
  }

  render() {
    return(
      <div>
        {!this.state.selectedShow ? (
          <React.Fragment>
            <SearchBar searchTerm={this.state.searchTerm} handleChange={this.handleChange} handleSubmit={this.handleSubmit}/>
            { this.state.searchMade && !this.state.results_found && <h2>Not Found, try refining your search</h2>}
            { this.state.results_found && <Results source="plex" results={this.state.plexResults} selectShow={this.selectShow}/>}
            { this.state.results_found && <div id="line-break"/>}
            { this.state.results_found && <Results source="tvdb" results={this.state.tvdbResults} selectShow={this.selectShow} />}
          </React.Fragment>
        )
        :
        (
          <SelectedShow selectedShow={this.state.selectedShow} />
        )
      }
      </div>
    )
  }
}

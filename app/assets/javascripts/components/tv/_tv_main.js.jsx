class FilmMain extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      searchTerm: "",
      plexResults: [],
      omdbResults: [],
      results_found: false,
      searchMade: false,
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
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
        console.log(json)
        if (json.results_found) {
          const plexResults = json.plex.results || []
          const omdbResults = json.omdb.results || []
          this.setState({
            searchMade: true,
            results_found: true,
            omdbResults: omdbResults,
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

  render() {
    return(
      <div>
        <h1>Film Findr</h1>
        <SearchBar searchTerm={this.state.searchTerm} handleChange={this.handleChange} handleSubmit={this.handleSubmit}/>
        { this.state.searchMade && !this.state.results_found && <h2>Not Found, try refining your search</h2>}
        { this.state.results_found && <Results source="plex" results={this.state.plexResults} />}
        { this.state.results_found && <div id="line-break"/>}
        { this.state.results_found && <Results source="omdb" results={this.state.omdbResults} />}
      </div>
    )
  }
}

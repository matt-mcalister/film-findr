class Main extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      searchTerm: "",
      plexResults: [],
      ytsResults: [],
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
    fetch("/api/v1/films", {
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
          const ytsResults = json.yts.results || []
          const plexResults = json.plex.results || []
          this.setState({
            searchMade: true,
            results_found: true,
            ytsResults: ytsResults,
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
        { this.state.results_found && <Results source="yts" results={this.state.ytsResults} />}
      </div>
    )
  }
}

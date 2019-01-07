class Main extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      searchTerm: "",
      results: [],
      source: "plex"
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
      .then(({ results, source }) => {
        this.setState({
          results,
          source
        })
      })
  }

  render() {
    return(
      <div>
        <h1>Film Findr</h1>
        <SearchBar searchTerm={this.state.searchTerm} handleChange={this.handleChange} handleSubmit={this.handleSubmit}/>
        {(this.state.results.length > 0 || this.state.source == "not found") && <Results results={this.state.results} source={this.state.source}/>}
      </div>
    )
  }
}

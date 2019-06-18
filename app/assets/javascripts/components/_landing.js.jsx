class Landing extends React.Component {

  constructor(props){
    super(props)
    this.state = {
      results: null
    }
    this.handleSearch = this.handleSearch.bind(this)
  }

  handleSearch(results){
    this.setState({
      results: results
    })
  }

  render() {
    return (
      <div>
        <NavBar handleSearch={this.handleSearch}/>
        {
          this.state.results && <SearchResults results={this.state.results} />
        }
      </div>
    )
  }
}

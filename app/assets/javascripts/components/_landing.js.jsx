class Landing extends React.Component {

  constructor(props){
    super(props)
    this.state = {
      loading: false,
      results: null,
      searchType: null
    }
    this.handleSearch = this.handleSearch.bind(this)
    this.beginSearch = this.beginSearch.bind(this)
  }

  handleSearch({ results, searchType }){
    this.setState({
      loading: false,
      results,
      searchType
    })
  }

  beginSearch(){
    this.setState({
      loading: true,
      results: null,
      searchType: null
    })
  }

  render() {
    return (
      <div>
        <NavBar handleSearch={this.handleSearch} beginSearch={this.beginSearch}/>
        {
          this.state.results && !this.state.loading && <SearchResults results={this.state.results} searchType={this.state.searchType} />
        }
        {
          this.state.loading && <Loading />
        }
      </div>
    )
  }
}

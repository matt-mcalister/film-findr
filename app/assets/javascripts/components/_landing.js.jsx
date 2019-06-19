class Landing extends React.Component {

  constructor(props){
    super(props)
    this.state = {
      loading: false,
      results: null,
      searchType: null,
      selectedItem: null
    }
    this.handleSearch = this.handleSearch.bind(this)
    this.beginSearch = this.beginSearch.bind(this)
    this.selectItem = this.selectItem.bind(this)
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
      selectedItem: null,
      results: null,
      searchType: null
    })
  }

  selectItem(item){
    this.setState({
      selectedItem: item
    })
  }

  render() {
    return (
      <div>
        <NavBar handleSearch={this.handleSearch} beginSearch={this.beginSearch}/>
        {
          this.state.loading ? <Loading /> :
          this.state.results && !this.state.selectedItem ? <SearchResults results={this.state.results} searchType={this.state.searchType} selectItem={this.selectItem}/> :
          this.state.selectedItem && <SelectedItem searchType={this.state.searchType} item={this.state.selectedItem} />
        }
      </div>
    )
  }
}

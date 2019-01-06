class Main extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      searchTerm: "",
      results: []
    }
    this.handleChange = this.handleChange.bind(this)
  }

  handleChange(e) {
    this.setState({
      searchTerm: e.target.value
    })
  }

  render() {
    return(
      <div>
        <h1>Film Findr</h1>
        <SearchBar searchTerm={this.state.searchTerm} handleChange={this.handleChange}/>
        <Results results={this.state.results}/>
      </div>
    )
  }
}

class NavBar extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      searchTerm: "",
      searchType: "film"
    }
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleChange = this.handleChange.bind(this)
  }

  handleChange(e){
    this.setState({
      [e.target.name]: e.target.value
    })
  }

  handleSubmit(e){
    e.preventDefault()
    let route = this.state.searchType === "film" ? "films" : "films/tv"
    fetch(`/api/v1/${route}`, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        search_term: this.state.searchTerm
      })
    }).then(res => res.json())
      .then(({ results }) => {
        this.props.handleSearch(results)
      })
  }

  render(){
    return (
      <div className="flex row center space-between navbar">
        <form className="flex row search-bar space-between" onSubmit={this.handleSubmit}>
          <input type="text" value={this.state.searchTerm} name="searchTerm" onChange={this.handleChange} />
          <select id="media-selector" value={this.state.searchType} name="searchType" onChange={this.handleChange}>
            <option value="film">Film</option>
            <option value="tv">TV</option>
          </select>
          <input type="submit" value="Search"/>
        </form>
      </div>
    )
  }
}

class SelectedItem extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      description: props.searchType === "film" ? null : props.item.overview,
    }
  }

  componentDidMount(){
    if (this.props.searchType === "film"){
      fetch("/api/v1/films/info", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          imdb_id: this.props.item.imdbID
        })
      }).then(res => res.json()).then(data => {
        this.setState({
          description: data.Plot
        })
      })
    }
  }

  render(){
    let {searchType, item} = this.props
    let poster = "image_url"
    let title = "seriesName"
    let year = "firstAired"
    if (searchType === "film") {
      poster = "Poster"
      title = "Title"
      year = "Year"
    }
    let img = item[poster] === "N/A" ? "http://www.reelviews.net/resources/img/default_poster.jpg" : item[poster]
    return (
        <div className="flex row flex-wrap selected-item center space-around">
          <img src={img} alt={item[title]} />
          <div>
            <h4>{item[title]} {item[year] && `(${item[year].split("-")[0]})`}</h4>
            {this.state.description && <p>{this.state.description}</p>}
            {searchType === "film" ? <FilmTors title={item[title]} imdbID={item.imdbID}/> : <TVTors tvdbId={item.id} slug={item.slug} seriesName={item.seriesName}/>}
          </div>
        </div>
    )
  }
}

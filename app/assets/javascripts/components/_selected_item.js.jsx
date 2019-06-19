class SelectedItem extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      torrents: null,
      torrentSearched: false,
    }
  }

  render(){
    let {searchType, item} = this.props
    let poster = "image_url"
    let title = "seriesName"
    let year = "firstAired"
    let description = "overview"
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
        {item[description] && <p>{item[description]}</p>}
        {searchType === "film" ? <FilmTors imdbID={item.imdbID}/> : <TVTors tvdbId={item.id} />}
      </div>
      </div>
    )
  }
}

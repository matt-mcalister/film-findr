class SelectedShow extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      seasons: {}
    }
  }

  componentDidMount(){
    const plex_id = this.props.selectedShow.ratingKey || null
    fetch("/api/v1/films/get_seasons", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        tvdb_id: this.props.selectedShow.tvdb_content.id,
        plex_id: plex_id
      })
    }).then(r => r.json())
      .then(seasons => {
        this.setState({
          seasons: seasons
        })
      })
  }


  render(){
    console.log(this.state);
    const { seriesName, image_url } = this.props.selectedShow.tvdb_content
    return (
      <div id="selected-show">
        <h1>{seriesName}</h1>
        <img src={image_url} alt={seriesName} />
      </div>
    )
  }
}

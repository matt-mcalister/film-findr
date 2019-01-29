class PlexItem extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      image_url: ""
    }
    this.handleClick = this.handleClick.bind(this)
  }

  componentDidMount(){
    if (this.props.omdb_content) {
      this.setState({
        image_url: this.props.omdb_content.Poster
      })
    } else {
      fetch("/api/v1/films/thumbnail", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          thumb: this.props.thumb
        })
      }).then(res => res.blob()).then(blob => {
        const image_url = URL.createObjectURL(blob)
        this.setState({
          image_url: image_url
        })
      })
    }
  }

  handleClick(){
    let show = {...this.props, image_url: this.state.image_url}
    delete show.selectShow
    this.props.selectShow(show)
  }

  render(){
    return(
      <div className="item plex">
        <img src={this.state.image_url} alt={this.props.title} />
        <h4>{this.props.title} ({this.props.year})</h4>
        {this.props.omdb_content && <button onClick={this.handleClick}>View Seasons</button>}
      </div>
    )
  }
}

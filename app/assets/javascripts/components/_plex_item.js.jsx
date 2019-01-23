class PlexItem extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      image_url: ""
    }
  }

  componentDidMount(){
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
  render(){
    console.log(this.props);
    return(
      <div className="item plex">
        <img src={this.state.image_url} alt={this.props.title} />
        <h4>{this.props.title} ({this.props.year})</h4>
      </div>
    )
  }
}

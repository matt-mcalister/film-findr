class PlexItem extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      image_url: ""
    }
  }

  componentDidMount(){
    fetch("http://127.0.0.1:32400" + this.props.thumb, {
       headers: {
          "Accept":"application/json",
          "X-Plex-Token":"EJMAqACEwzswyYszGpsb"
      }
      }).then(res => res.blob()).then(blob => {
        const image_url = URL.createObjectURL(blob)
         this.setState({
           image_url: image_url
         })
      })
  }
  render(){
    return(
      <div className="item plex">
      <img src={this.state.image_url} alt={this.props.title} />
      <h4>{this.props.title} ({this.props.year})</h4>
      </div>
    )
  }
}

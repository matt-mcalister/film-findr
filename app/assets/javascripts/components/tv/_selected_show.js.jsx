class SelectedShow extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      seasonCount: 0
    }
  }
  render(){
    console.log(this.props);
    const { seriesName, image_url } = this.props.selectedShow.tvdb_content
    return (
      <div id="selected-show">
        <h1>{seriesName}</h1>
        <img src={image_url} alt={seriesName} />
      </div>
    )
  }
}

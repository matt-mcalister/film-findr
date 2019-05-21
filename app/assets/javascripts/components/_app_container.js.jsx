class AppContainer extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      mediaType: props.mediaType
    }
    this.handleChange = this.handleChange.bind(this)
  }

  handleChange(e){
    console.log(e.target.value);
    console.log(e.target.selectedValue);
    this.setState({
      mediaType: e.target.value
    })
  }

  render(){
    return (
      <div>
        <select id="media-selector" name={"mediaType"} value={this.state.mediaType} onChange={this.handleChange}>
          <option value={"film"}>Film Findr</option>
          <option value={"tv"}>TV Findr</option>
        </select>
        {this.state.mediaType === "film" ?
        <FilmMain />
        :
        <TVMain />
        }
      </div>
    )
  }
}

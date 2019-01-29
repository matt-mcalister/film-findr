class SelectedShow extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      seasonCount: 0
    }
  }
  render(){
    console.log(this.props);
    const { Title, Poster } = this.props.selectedShow.omdb_content
    return (
      <div id="selected-show">
        <h1>{Title}</h1>
        <img src={Poster} alt={Title} />
      </div>
    )
  }
}

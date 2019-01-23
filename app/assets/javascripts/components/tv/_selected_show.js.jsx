class SelectedShow extends React.Component {
  render(){
    console.log(this.props);
    return (
      <div id="selected-show">
        {this.props.selectedShow.title}
      </div>
    )
  }
}

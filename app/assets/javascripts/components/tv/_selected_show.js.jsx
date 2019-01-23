class SelectedShow extends React.Component {
  render(){
    const { title, image_url } = this.props.selectedShow
    return (
      <div id="selected-show">
        <h1>{title}</h1>
        <img src={image_url} alt={title} />
      </div>
    )
  }
}

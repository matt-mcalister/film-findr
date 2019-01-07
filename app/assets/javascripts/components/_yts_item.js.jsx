const YTSItem = (props) => {
  console.log(props)
    return(
      <div className="item yts">
        <img src={props.medium_cover_image} alt={props.title} />
        <p>{props.title}</p>
      </div>
    )
}

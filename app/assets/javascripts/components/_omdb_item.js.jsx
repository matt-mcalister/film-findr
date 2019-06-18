const OMDBItem = (props) => {
    function handleClick(e){
      let item = {...props}
      delete item.selectItem
      props.selectItem(item)
    }
    let img = props.image_url === "N/A" ? "http://www.reelviews.net/resources/img/default_poster.jpg" : props.Poster
    return(
      <div className="item center-text">
        <img src={img} alt={props.Title} />
        <h4>{props.Title} {props.Year && `(${props.Year.split("-")[0]})`}</h4>
        <button onClick={handleClick}>See More Info</button>
      </div>
    )
}

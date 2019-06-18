const OMDBItem = (props) => {
    // function handleClick(e){
    //   let show = {tvdb_content: {...props}}
    //   delete show.tvdb_content.selectShow
    //   props.selectShow(show)
    // }
    let img = props.image_url === "N/A" ? "http://www.reelviews.net/resources/img/default_poster.jpg" : props.Poster
    return(
      <div className="item center-text">
        <img src={img} alt={props.Title} />
        <h4>{props.Title} {props.Year && `(${props.Year.split("-")[0]})`}</h4>
        <button onClick={console.log}>See More Info</button>
      </div>
    )
}

const OMDBItem = (props) => {
    function handleClick(e){
      let show = {omdb_content: {...props}}
      delete show.omdb_content.selectShow
      props.selectShow(show)
    }
    let img = props.Poster === "N/A" ? "http://www.reelviews.net/resources/img/default_poster.jpg" : props.Poster
    return(
      <div className="item yts">
        <img src={img} alt={props.Title} />
        <h4>{props.Title} ({props.Year})</h4>
        <button onClick={handleClick}>See More Info</button>
      </div>
    )
}

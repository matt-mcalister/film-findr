const OMDBItem = (props) => {
    console.log(props);
    let img = props.Poster === "N/A" ? "http://www.reelviews.net/resources/img/default_poster.jpg" : props.Poster
    return(
      <div className="item yts">
        <img src={img} alt={props.Title} />
        <h4>{props.Title} ({props.Year})</h4>
        <button>See More Info</button>
      </div>
    )
}

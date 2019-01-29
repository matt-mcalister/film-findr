const TVDBItem = (props) => {
    function handleClick(e){
      let show = {tvdb_content: {...props}}
      delete show.tvdb_content.selectShow
      props.selectShow(show)
    }
    let img = props.image_url === "N/A" ? "http://www.reelviews.net/resources/img/default_poster.jpg" : props.image_url
    return(
      <div className="item tvdb">
        <img src={img} alt={props.seriesName} />
        <h4>{props.seriesName} ({props.firstAired.split("-")[0]})</h4>
        <button onClick={handleClick}>See More Info</button>
      </div>
    )
}

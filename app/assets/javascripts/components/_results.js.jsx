const Results = ({results, source}) => {
    switch (source) {
      case "plex":
        return (
          <React.Fragment>
            <h2>CURRENTLY IN PLEX:</h2>
            <div className="flex">
              { results.length > 0 ?
                results.map(item => <PlexItem key={item.id} {...item} />) :
                <p>Not Found</p>
              }
            </div>
          </React.Fragment>
        )
      case "yts":
        return (
          <React.Fragment>
            <h2>ADD TO PLEX:</h2>
            <div className="flex">
              { results.length > 0 ?
                results.map(item => <YTSItem key={item.id} {...item} />) :
                <p>Not Found</p>
              }
            </div>
          </React.Fragment>
        )
      case "omdb":
        return (
          <React.Fragment>
            <h2>ADD TO PLEX:</h2>
            <div className="flex">
              { results.length > 0 ?
                results.map(item => <OMDBItem key={item.imdbID} {...item} />) :
                <p>Not Found</p>
              }
            </div>
          </React.Fragment>
        )
      case "not found":
        return <h3>Not Found</h3>
      default:
        return <h3>Not Found</h3>
    }

}

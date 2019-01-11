const Results = ({results, source}) => {
    switch (source) {
      case "plex":
        return (
          <React.Fragment>
            <h2>PLEX</h2>
            <div className="flex">
              {results.map(item => <PlexItem key={item.id} {...item} />)}
            </div>
          </React.Fragment>
        )
      case "yts":
        return (
          <React.Fragment>
            <h2>YTS</h2>
            <div className="flex">
              {results.map(item => <YTSItem key={item.id} {...item} />)}
            </div>
          </React.Fragment>
        )
      case "not found":
        return <h3>Not Found</h3>
      default:
        return <h3>Not Found</h3>
    }

}

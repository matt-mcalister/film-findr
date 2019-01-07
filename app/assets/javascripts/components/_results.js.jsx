const Results = ({results, source}) => {
    switch (source) {
      case "plex":
        return (
          <div className="flex">
            {results.map(item => <PlexItem {...item} />)}
          </div>
        )
      case "yts":
        return (
          <div className="flex">
            {results.map(item => <YTSItem {...item} />)}
          </div>
        )
      case "not found":
        return <h3>Not Found</h3>
      default:
        return <h3>Not Found</h3>
    }

}

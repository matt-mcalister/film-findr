const Results = ({results, source, selectShow}) => {
    switch (source) {
      case "plex":
        return (
          <React.Fragment>
            <h2>CURRENTLY IN PLEX:</h2>
            <div className="flex">
              { results.length > 0 ?
                results.map(item => <PlexItem key={item.id} {...item} selectShow={selectShow}/>) :
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
      case "tvdb":
        return (
          <React.Fragment>
            <h2>ADD TO PLEX:</h2>
            <div className="flex">
              { results.length > 0 ?
                results.map(item => <TVDBItem key={item.id} {...item}  selectShow={selectShow}/>) :
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

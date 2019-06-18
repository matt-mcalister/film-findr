const SearchResults = ({ results, searchType, selectItem }) => {
  console.log("RESULTS: ", results)
  if (!results || results.length === 0) {
    return <h1>Not Found</h1>
  }
  let resultItems = searchType === "film" ? results.map(item => <OMDBItem key={item.imdbID} {...item} selectItem={selectItem}/>) : results.map(item => <TVDBItem key={item.id} {...item} selectItem={selectItem}/>)
  return (
    <div className="flex flex-wrap search-results">
      {resultItems}
    </div>
  )
}

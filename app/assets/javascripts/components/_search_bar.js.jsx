const SearchBar = (props) => {
    return(
      <form>
        <input type="test" value={props.searchTerm} onChange={props.handleChange} />
      </form>
    )
}

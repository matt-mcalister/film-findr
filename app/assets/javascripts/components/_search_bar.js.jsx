const SearchBar = (props) => {
    return(
      <form onSubmit={props.handleSubmit}>
        <input type="test" value={props.searchTerm} onChange={props.handleChange} />
        <input type="submit"/>
      </form>
    )
}

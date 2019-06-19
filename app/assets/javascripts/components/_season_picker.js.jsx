const SeasonPicker = ({ seasons, selectedSeason, selectSeason }) => {
  return (
    <select value={selectedSeason} onChange={selectSeason}>
      {seasons.map(s => <option key={s} value={s}>Season {s}</option>)}
    </select>
  )
}

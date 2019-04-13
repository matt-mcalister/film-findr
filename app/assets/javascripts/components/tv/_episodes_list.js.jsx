const EpisodesList = ({ episodes, addToPlex }) => {
  return (
    <div className="flex">
      {Object.keys(episodes).map(epNum => <EpisodeItem key={epNum} episode={episodes[epNum]} addToPlex={(e) => addToPlex(episodes[epNum])}/>)}
    </div>
  )
}

const EpisodesList = ({ episodes, addToPlex }) => {
  return (
    <div className="flex row flex-wrap scroll-y episode-list">
      {Object.keys(episodes).map(epNum => <EpisodeItem key={epNum} episode={episodes[epNum]} addToPlex={(e) => addToPlex(episodes[epNum])}/>)}
    </div>
  )
}

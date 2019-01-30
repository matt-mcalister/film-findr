const EpisodesList = ({ episodes, addToPlex }) => {
  console.log(episodes);
  return (
    <div className="flex">
      {Object.keys(episodes).map(epNum => <EpisodeItem key={epNum} episode={episodes[epNum]} addToPlex={(e) => addToPlex(epNum)}/>)}
    </div>
  )
}

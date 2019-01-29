const EpisodesList = ({ episodes }) => {
  console.log(episodes);
  return (
    <div>
      {Object.keys(episodes).map(epNum => <EpisodeItem key={epNum} episode={episodes[epNum]} />)}
    </div>
  )
}

const DownloadFilm = ({ tor, resolution }) => {
  let size = "size"
  if (tor.source === "YTS"){
    size = "size_bytes"
  }
  return <button>{resolution} - {(tor[size] * 10**-9).toFixed(2)}GB</button>
}

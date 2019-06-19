const DownloadFilm = ({ tor, resolution, download }) => {
  let size = "size"
  if (tor.source === "YTS"){
    size = "size_bytes"
  }
  return <button onClick={download}>{resolution} - {(tor[size] * 10**-9).toFixed(2)}GB</button>
}

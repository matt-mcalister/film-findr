class Api::V1::FilmsController < ApplicationController
  skip_before_action :verify_authenticity_token


  def search

    term = params[:search_term]

    query = PlexAPI::Query.new(term, :film)
    query.search_with_torrents

    if query.results || query.torrents
      render json: {
        results_found: true,
        plex: { results: query.results },
        yts: { results: query.torrents }
      }
    else
      render json: { results_found: false }
    end
  end

  def get_4k
    rarbg = RARBG::API.new
    torrent_results = rarbg.search(imdb: params[:imdb_id], category: [50, 51, 52],format: :json_extended)
    if torrent_results.empty?
      render json: {found_torrent: false}
    else
      categories = {"Movs/x265/4k/HDR" => 3, "Movies/x265/4k" => 2, "Movies/x264/4k" => 1 }
      top_uhd_torrent = torrent_results.first
      torrent_results[1..-1].each do |tor|
        if categories[tor["category"]] > categories[top_uhd_torrent["category"]] || (categories[tor["category"]] == categories[top_uhd_torrent["category"]] && tor["seeders"] + tor["leechers"] > top_uhd_torrent["seeders"] + top_uhd_torrent["leechers"])
          top_uhd_torrent = tor
        end
      end
      render json: {found_torrent: true, torrent: top_uhd_torrent}

    end
  end

  def tv_search

    term = params[:search_term]

    query = PlexAPI::Query.new(term, :tv)
    query.search_with_torrents

    if query.results || query.torrents
      render json: {
        results_found: true,
        plex: { results: query.results },
        tvdb: { results: query.torrents }
      }
    else
      render json: { results_found: false }
    end
  end

  def get_seasons
    seasons = PlexAPI.get_seasons_with_torrents(tvdb_id: params[:tvdb_id], plex_id: params[:plex_id])
    render json: seasons
  end

  def thumbnail
    image_res = PlexAPI.image(params[:thumb])
    render plain: image_res.body
  end

  def download
    QBitAPI.add_torrent(torrent_hash: params[:torrent_hash], type: params[:type], magnet_url: params[:magnet_url], season: params[:season], episode: params[:episode], show_title: params[:show_title])
  end

end

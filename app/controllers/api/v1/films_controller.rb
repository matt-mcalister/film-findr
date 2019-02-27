class Api::V1::FilmsController < ApplicationController
  skip_before_action :verify_authenticity_token


  def search

    term = params[:search_term]

    yts_response = HTTParty.get("https://yts.am/api/v2/list_movies.json?quality=1080p&limit=50&query_term=#{term}")
    # yts_response = nil
    plex_results = PlexAPI::Query.new(term, :film).search || []
    yts_results = []

    if yts_response && yts_response["data"]["movies"]
      yts_results = yts_response["data"]["movies"].uniq
      yts_results.reject! {|movie| plex_results.any? {|m| m["title"] == movie["title"] && m["year"] == movie["year"]} }
    end

    if plex_results || yts_response && yts_results
      render json: {
        results_found: true,
        plex: { results: plex_results },
        yts: { results: yts_results }
      }
    else
      render json: { results_found: false }
    end
  end

  def tv_search

    term = params[:search_term]

    plex_results = PlexAPI::Query.new(term, :tv).search || []
    tvdb_results = TVDBQuery.search_by_name(term)

    tvdb_results.reject! do |show|
      plex_results.any? do |s|
        if s["title"] == show["seriesName"] && s["year"] == show["firstAired"].to_i
          s["tvdb_content"] = show
        else
          false
        end
      end
    end

    if plex_results || tvdb_results
      render json: {
        results_found: true,
        plex: { results: plex_results },
        tvdb: { results: tvdb_results }
      }
    else
      render json: { results_found: false }
    end
  end

  def get_seasons
    seasons = TVDBQuery.get_seasons(tvdb_id: params[:tvdb_id], plex_id: params[:plex_id])
    render json: seasons
  end

  def thumbnail
    image_res = PlexAPI.image(params[:thumb])
    render plain: image_res.body
  end

  def download
    `open magnet:?xt=urn:btih:#{params[:hash]}&dn=#{params[:slug]}&tr=udp://tracker.openbittorrent.com:80`
  end
end

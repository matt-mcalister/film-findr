class Api::V1::FilmsController < ApplicationController
  skip_before_action :verify_authenticity_token

  @@base_url = "http://127.0.0.1:32400"
  @@token = "EJMAqACEwzswyYszGpsb"
  @@options = {
    headers: {
      "Accept" => "application/json",
      "X-Plex-Token" => @@token
    }
  }

  def search

    term = params[:search_term]

    plex_response = HTTParty.get("#{@@base_url}/search?query=#{term}", @@options)
    # yts_response = HTTParty.get("https://yts.am/api/v2/list_movies.json?quality=1080p&limit=50&query_term=#{term}")
    yts_response = nil
    plex_results = []
    yts_results = []
    if plex_response && plex_response["MediaContainer"]["Metadata"] && plex_response["MediaContainer"]["Metadata"].length > 0
      plex_results = plex_response["MediaContainer"]["Metadata"]
    end

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

    plex_response = HTTParty.get("#{@@base_url}/search?query=#{term}", @@options)
    # yts_response = HTTParty.get("https://yts.am/api/v2/list_movies.json?quality=1080p&limit=50&query_term=#{term}")
    yts_response = nil
    plex_results = []
    yts_results = []
    if plex_response && plex_response["MediaContainer"]["Metadata"] && plex_response["MediaContainer"]["Metadata"].length > 0
      plex_results = plex_response["MediaContainer"]["Metadata"]
    end

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

  def thumbnail
    image_res = HTTParty.get("#{@@base_url}#{params[:thumb]}", @@options)
    render plain: image_res.body
  end

  def download
    `open magnet:?xt=urn:btih:#{params[:hash]}&dn=#{params[:slug]}&tr=udp://tracker.openbittorrent.com:80`
  end
end

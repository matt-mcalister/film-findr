class Api::V1::FilmsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def search
    base_url = "http://127.0.0.1:32400"
    token = "EJMAqACEwzswyYszGpsb"
    term = params[:search_term]
    options = {
      headers: {
        "Accept" => "application/json",
        "X-Plex-Token" => token
      }
    }
    plex_response = HTTParty.get("#{base_url}/search?query=#{term}", options)
    yts_response = HTTParty.get("https://yts.am/api/v2/list_movies.json?quality=1080p&limit=50&query_term=#{term}")
    # if response && response["MediaContainer"]["Metadata"] && response["MediaContainer"]["Metadata"].length > 0
    #   render json: {results: response["MediaContainer"]["Metadata"], source: "plex"}
    # else
    #   if response["data"]["movies"]
    #     render json: {results: response["data"]["movies"], source: "yts"}
    #   else
    #     render json: {results: [], source: "not found"}
    #   end
    # end

    if (plex_response && plex_response["MediaContainer"]["Metadata"] && plex_response["MediaContainer"]["Metadata"].length > 0) || yts_response && yts_response["data"]["movies"]
      render json: {
        results_found: true,
        plex: { results: plex_response["MediaContainer"]["Metadata"] },
        yts: { results: yts_response["data"]["movies"] }
      }
    else
      render json: { results_found: false }
    end
  end

  def download
    `open magnet:?xt=urn:btih:#{params[:hash]}&dn=#{params[:slug]}&tr=udp://tracker.openbittorrent.com:80`
  end
end

class Api::V1::FilmsController < ApplicationController
  skip_before_action :verify_authenticity_token


  def search

    term = params[:search_term]

    # plex_response = HTTParty.get("#{@@base_url}/library/sections/1/search?type=1&query=#{term}", @@options)
    yts_response = nil
    plex_results = PlexAPI::Query.new(term, :film).search
    yts_results = []
    # if plex_response && plex_response["MediaContainer"]["Metadata"] && plex_response["MediaContainer"]["Metadata"].length > 0
    #   plex_results = plex_response["MediaContainer"]["Metadata"]
    # end

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

    plex_results = PlexAPI::Query.new(term, :tv).search
    omdb_results = OMDBQuery.new(term).search

    omdb_results.reject! do |show|
      plex_results.any? do |s|
        if s["title"] == show["Title"] && s["year"] == show["Year"].to_i
          s["imdbID"] = show["imdbID"]
        else
          false
        end
      end
    end

    if plex_results || omdb_results
      render json: {
        results_found: true,
        plex: { results: plex_results },
        omdb: { results: omdb_results }
      }
    else
      render json: { results_found: false }
    end
  end

  def thumbnail
    image_res = PlexAPI.image(params[:thumb])
    render plain: image_res.body
  end

  def download
    `open magnet:?xt=urn:btih:#{params[:hash]}&dn=#{params[:slug]}&tr=udp://tracker.openbittorrent.com:80`
  end
end

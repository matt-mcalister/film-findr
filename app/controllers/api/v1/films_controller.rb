class Api::V1::FilmsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def search
    # byebug
    base_url = "http://127.0.0.1:32400"
    token = "EJMAqACEwzswyYszGpsb"
    term = params[:search_term]
    options = {
      headers: {
        "Accept" => "application/json",
        "X-Plex-Token" => token
      }
    }
    response = HTTParty.get("#{base_url}/search?query=#{term}", options)
    if response && response["MediaContainer"]["Metadata"] && response["MediaContainer"]["Metadata"].length > 0
      render json: {results: response["MediaContainer"]["Metadata"], source: "plex"}
    else
      response = HTTParty.get("https://yts.am/api/v2/list_movies.json?quality=1080p&limit=50&query_term=#{term}")
      if response["data"]["movies"]
        render json: {results: response["data"]["movies"], source: "yts"}
      else
        render json: {results: [], source: "not found"}
      end
    end
  end

  def download

  end
end

class Api::V1::FilmsController < ApplicationController

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

    render json: response["MediaContainer"]["Metadata"]
  end

  def download

  end
end

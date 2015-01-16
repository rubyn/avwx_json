class MetarsController < ApplicationController
  def show
  	#If invalid params respond with invalid params message and status code
  	#Else
    metars = Metars.new(params)
    if params[:raw_only]
      render json: metars.raw_data, status: 200
    else
      render json: metars, status: 200
    end
  end
end

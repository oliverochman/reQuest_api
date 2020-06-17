# frozen_string_literal: true

class Api::MyRequest::RequestsController < ApplicationController
  before_action :authenticate_user!, only: %i[update]

  def update
    if request_params[:activity] = 'complete'
      begin
        request = Request.find(request_params[:id])
        request.status = 'completed'
        request.save
        render json: { message: 'Request completed!' }
      rescue StandardError => e
        render json: { message: 'Something went wrong: ' + e.message }, status: 422
      end
    end
  end

  private

  def request_params
    params.permit(:activity, :id)
  end
end

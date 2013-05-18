class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token

  #rescue_from Exception, with: :error_render_method

  #before_filter :authenticate_user!

  respond_to :json

  private

  def error_render_method exception
    if Rails.env.production?
      render json: { message: exception.message }, status: 500
    else
      raise exception
    end
  end
end

class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
  end

  def templates
    render action: params[:id]
  end
end

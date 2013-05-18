class TemplatesController < ApplicationController
  layout false

  def show
    render action: params[:id]
  end
end

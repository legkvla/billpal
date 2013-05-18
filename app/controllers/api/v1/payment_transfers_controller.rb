class Api::V1::PaymentTransfersController < ApiController
  before_filter :authenticate_user!

  def create
    if params[:contact_to].present? && params[:amount].present? && params[:payment_method].present?

    end
  end
end

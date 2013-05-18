class Api::V1::PaymentTransfersController < ApiController
  before_filter :authenticate_user!

  def create
    if params[:contact_to].present? && params[:amount].present? && params[:payment_method].present?
      payment = current_user.create_payment(params[:amount],
                                            params[:contact_to][:kind],
                                            params[:contact_to][:uid],
                                            params[:payment_method])
      if payment.valid?
        render json: {payment_invoice_id: payment_invoice.id}
      else
        render json: {status: 'invalid payment data'}, status: 500
      end
    else
      render json: {status: 'invalid params'}, status: 500
    end
  end
end

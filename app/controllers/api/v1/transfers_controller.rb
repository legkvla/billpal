class Api::V1::TransfersController < ApiController
  before_filter :authenticate_user!

  def create
    if params[:contact_to_kind].present? && params[:contact_to_uid].present? && params[:amount].present? &&
        params[:payment_method].present?

      transfer = current_user.create_transfer(
          params[:amount],
          params[:contact_to_kind],
          params[:contact_to_uid],
          params[:payment_method])
      if transfer.valid?
        render json: {status: 'ok', charge_id: transfer.uid}
      else
        render json: {status: 'invalid payment data'}, status: 500
      end
    else
      render(json: {
          status: 'invalid params',
          contact_to_kind: params[:contact_to_kind],
          contact_to_uid: params[:contact_to_uid],
          amount: params[:amount],
          payment_method: params[:payment_method]
      }, status: 500)
    end
  end

  def withdrawal
    transfer = Transfer.find(params[:id])
  end
end

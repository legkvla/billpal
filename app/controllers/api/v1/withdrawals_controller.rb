class Api::V1::WithdrawalsController < ApiController
  def create
    if params[:payment_data].present? && params[:amount].present? && params[:payment_method].present?
      withdrawal = current_user.withdrawals.new(
          {
              amount: params[:amount],
              kind: params[:payment_method],
              params: params[:payment_data],
              payment_kind: :just_gateway
          }, without_protection: true)
      if withdrawal.amount < current_user.balance.amount && withdrawal.save
        render json: {status: 'ok'}
      else
        render json: {status: 'invalid payment data'}, status: 500
      end
    else
      render(json: {
          status: 'invalid params',
          payment_data: params[:payment_data],
          amount: params[:amount],
          payment_method: params[:payment_method]
      }, status: 500)
    end
  end
end

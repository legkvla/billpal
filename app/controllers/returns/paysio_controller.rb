class Returns::PaysioController < ReturnsController
  def return
    charge = Paysio::Charge.retrieve params[:charge_id]
    payment = Payment.where(uid: params[:charge_id], payment_kind_cd: Payment.payment_kinds(:paysio)).first
    payment.pay if charge.status == 'paid'

    redirect_to dashboard_url
  end
end

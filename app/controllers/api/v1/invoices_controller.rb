class Api::V1::InvoicesController < ApiController
  before_filter :authenticate_user!

  def create
    if params[:amount].present?
      invoice = current_user.create_invoice(params[:amount])
      if invoice.valid?
        render json: {status: 'ok', url: from_email_invoice_url(invoice, invoice.slug)}
      else
        render json: {status: 'invalid amount'}, status: 500
      end
    else
      render(json: {
          status: 'invalid params',
          amount: params[:amount]
      }, status: 500)
    end
  end

  def withdrawal
    invoice = Invoice.find(params[:id])
  end
end

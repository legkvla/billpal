class Api::V1::BillsController < ApiController
  def create
    params[:amount_cents] = 0
    params[:to_user_attributes][:password] = "qwerty" unless params[:to_user_attributes].blank?

    attributes = params.dup
    %w[created_at action controller bill].each{ |k| attributes.delete k }

    bill = current_user.bills.new attributes.merge(:from_contact_id => current_user.contact.try(:id).to_i)

    if bill.save
      redirect_to(api_v1_bill_path(bill))
    else
      format_errors bill.errors.as_json
    end
  end

  def pay
    bill = Bill.find(params[:id])

    charge = bill.create_payment(:test)

    render json: charge.as_json
  end

  def cancel
    bill = Bill.find(params[:id])

    bill.cancel!

    redirect_to(api_v1_bill_path(bill))
  end

  def update
    bill = current_user.bills.find(params[:id])

    if bill.update_attributes(params)
      render json: bill
    else
      format_errors bill.errors.as_json
    end
  end

  def show
    bill = Bill.where('from_user_id = ? OR to_user_id = ?', current_user, current_user).find(params[:id])

    render json: bill.as_json.merge(fine: bill.fine)
  end

  def index
    bills = Bill.where('from_user_id = ? OR to_user_id = ?', current_user, current_user)

    bills_json = bills.map{|b| b.as_json.merge(
        fine: b.fine,
        direction: b.direction(current_user),
        to_user: b.to_user.as_json
    )}.as_json

    render json: bills_json
  end
end

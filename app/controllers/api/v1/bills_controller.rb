class Api::V1::BillsController < ApiController
  def create
    params[:amount_cents] = 0
    attributes = params.dup
    %w[created_at action controller bill].each{ |k| attributes.delete k }

    bill = current_user.bills.new attributes.merge(:from_contact_id => current_user.contact.try(:id).to_i)

    if bill.save
      render json: bill
    else
      format_errors bill.errors.as_json
    end
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

    render json: bill.as_json
  end

  def index
    bills = Bill.where('from_user_id = ? OR to_user_id = ?', current_user, current_user)

    render json: bills.as_json
  end
end

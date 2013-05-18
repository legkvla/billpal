class Api::V1::BillsController < ApiController
  def create
    params[:bill][:amount_cents] ||= 0
    bill = current_user.bills.new(params[:bill].merge(:from_contact_id => current_user.contact.id))

    if bill.save
      redirect_to api_v1_bill_path(bill)
    else
      render json: {
          errors: bill.errors.as_json
      }
    end
  end

  def update
    bill = current_user.bills.find(params[:id])

    if bill.update_attributes(params[:bill])
      redirect_to(api_v1_bill_path(bill))
    else
      render json: {
          errors: bill.errors.as_json
      }
    end
  end

  def show
    bill = Bill.where('from_user_id = ? OR to_user_id = ?', current_user, current_user).find(params[:id])

    render json: {
        errors: bill.as_json
    }
  end
end

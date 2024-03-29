class Api::V1::ItemsController < ApiController
  before_filter :find_bill

  def create
    item = @user_bill.items.new(params[:item])

    if item.save
      redirect_to api_v1_bill_item_path(@user_bill, item)
    else
      format_errors(item.errors.as_json)
    end
  end

  def update
    item = @user_bill.items.find(params[:id])

    if item.update_attributes(params[:item])
      redirect_to api_v1_bill_item_path(@user_bill, item)
    else
      format_errors item.errors.as_json
    end
  end

  def index
    render json: @shared_bill.items.as_json
  end

  def index_all_unique
    bills = Bill.where('from_user_id = ? OR to_user_id = ?', current_user, current_user)
    items = bills.map(&:items).flatten

    items_with_unique_names = items.uniq do |item|
      items.find_index {|i| i.title == item.title}
    end

    render json: (items_with_unique_names.map do |item|
      {
          title: item.title,
          unit_price: item.unit_price
      }
    end.as_json)
  end

  def show
    item = @shared_bill.items.find(params[:id])

    render json: item.as_json
  end

  def delete
    item = @user_bill.items.find(params[:id])

    if item.destroy
      redirect_to api_v1_bill_items_path(@user_bill)
    end
  end

  private

  def find_bill
    unless params[:action] == "index_all_unique"
      @shared_bill = Bill.where('from_user_id = ? OR to_user_id = ?', current_user, current_user).find(params[:bill_id])
      @user_bill = current_user.bills.find(params[:bill_id])
    end
  end
end

class Item < ActiveRecord::Base
  attr_accessible :title, :unit_price, :count

  belongs_to :bill

  before_save :update_amount_cents!
  after_save :update_bill_price!
  after_destroy :update_bill_price!

  validates_presence_of :title

  private

  def update_amount_cents!
    self.amount_cents = count * unit_price.to_i
  end

  def update_bill_price!
    bill.amount_cents = bill.items.map(&:amount_cents).sum
    bill.save!
  end
end

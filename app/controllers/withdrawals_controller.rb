class WithdrawalsController < ApplicationController
  layout 'only_topbar'

  def index
    @hide_controls = true
  end
end

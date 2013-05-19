class InvoicesController < ApplicationController
	layout '_invoice'

  def from_email

	end

	def show
		@invoice = Invoice.find(params[:id])
	end
end
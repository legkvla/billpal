class InvoicesController < ApplicationController
	layout '_invoice'

  def from_email

	end

	def show
		@invoice = Invoice.find(params[:id])

		respond_to do |format|
			format.html
			format.pdf do
				render pdf: 'invoice'
			end
		end
	end
end
class Api::V1::ContactsController < ApiController
  before_filter :authenticate_user!

  def create
    contact = current_user.contacts.new(params[:contact])

    if contact.save
      redirect_to api_v1_contact_path(contact)
    else
      render(json: {
          errors: contact.errors.as_json
      })
    end
  end

  def show
    contact = current_user.contacts.find(params[:id])

    render(json: contact.as_json)
  end

  def index
    render(json: contacts = current_user.contacts.as_json)
  end
end

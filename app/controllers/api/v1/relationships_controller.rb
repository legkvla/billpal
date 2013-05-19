class Api::V1::RelationshipsController < ApiController
  before_filter :authenticate_user!

  def create
    user = User.where(email: params[:email]).first
    if user.empty?
      user = User.create(email: params[:email], first_name: params[:first_name], last_name: params[:last_name])
    end

    current_user.relationships.build(followed_id: user.id)

    render nothing: true
  end

  def index
    render(json: current_user.followed_users.select([:id, :email, :first_name, :last_name]).as_json)
  end
end

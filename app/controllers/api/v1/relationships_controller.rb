class Api::V1::RelationshipsController < ApiController
  before_filter :authenticate_user!

  def create
    user = User.where(email: params[:email]).first
    if user.empty?
      user = User.create(
          {
              email: params[:email],
              first_name: params[:first_name],
              last_name: params[:last_name],
              password: SecureRandom.hex,
              role: 'anonymous'
          })
    end

    current_user.relationships.build(followed_id: user.id)

    render nothing: true
  end

  def index
    columns_string = %w[id email first_name last_name].map { |_| "users.#{_}" }.join(',')
    render(json: current_user.followed_users.select(columns_string).as_json)
  end
end

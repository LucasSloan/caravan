class ApiController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def login
    user = User.validate_user(params[:username], params[:password])
    puts user
    if user.is_a? User
      msg = { 'status code' => 1 }
    else
      msg = { 'status code' => user }
    end
    render :json => msg
    puts user
    puts params[:username]
    puts params[:password]
  end

  def create_user
    user = User.add(params[:username], params[:password])
    puts user
    if user.is_a? User
      msg = { 'status code' => 1 }
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

end

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

  def broadcast
    user = User.validate_user(params[:username], params[:password])
    if user.is_a? User
      lat = params[:latitude].to_f
      long = params[:longitude].to_f
      puts lat
      puts long
      if lat > 90 or lat < -90 or long > 180 or long < -180
        msg = { 'status code' => -3 }
      else
        user.start_broadcast(lat, long)
        msg = { 'status code' => 1 }
      end
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def follow
    location = User.follow(params[:username])
    puts location
    if location.is_a? Array
      msg = { 'status code' => 1 , 'latitude' => location[0], 'longitude' => location[1]}
    else
      msg = { 'status code' => location }
    end
    render :json => msg
  end

  def stop_broadcast
    user = User.validate_user(params[:username], params[:password])
    if user.is_a? User
      user.stop_broadcast
      msg = { 'status code' => 1 }
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

end

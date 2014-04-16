class ApiController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def login
    user = User.validate_user(params[:username], params[:password])
    if user.is_a? User
      msg = { 'status code' => 1 }
      session[:auth_token] = user.generate_auth_token
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def create_user
    user = User.add(params[:username], params[:password])
    if user.is_a? User
      msg = { 'status code' => 1 }
      session[:auth_token] = user.generate_auth_token
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def broadcast
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      lat = params[:latitude].to_f
      long = params[:longitude].to_f
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

  def set_follower_position
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      lat = params[:latitude].to_f
      long = params[:longitude].to_f
      if lat > 90 or lat < -90 or long > 180 or long < -180
        msg = { 'status code' => -3 }
      else
        if user.set_follower_position(lat, long)
          msg = { 'status code' => 1 }
        else
          msg = { 'status code' => -2 }
        end
      end
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def follow_request
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      msg = { 'status code' => User.follow_request(params[:username], user)}
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def follow_cancellation
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      msg = { 'status code' => User.follow_cancellation(params[:username], user)}
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def check_permission
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      msg = { 'status code' => user.check_permission(params[:username])}
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def follow
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      location = User.follow(params[:username], user)
      if location.is_a? Position
        msg = { 'status code' => 1 , 'latitude' => location.latitude, 'longitude' => location.longitude}
      else
        msg = { 'status code' => location - 2 }
      end
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def check_requesters
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      if user.broadcasting
        msg = { 'status code' => 1, 'follow requests' => user.check_requesters}
      else
        msg = { 'status code' => -3 }
      end
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def get_follower_positions
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      if user.broadcasting
        msg = { 'status code' => 1, 'user positions' => user.follower_positions}
      else
        msg = { 'status code' => -3 }
      end
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def invitation_response
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      msg = { 'status code' => user.invitation_response(params[:username])}
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def stop_broadcast
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      user.stop_broadcast
      msg = { 'status code' => 1 }
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def get_recently_followed
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      msg = { 'status code' => 1, 'history' => user.recently_followed}
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

end

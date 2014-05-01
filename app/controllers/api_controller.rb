require 'net/http'

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
    user = User.add(params[:username], params[:password], params[:email])
    if user.is_a? User
      msg = { 'status code' => 1 }
      session[:auth_token] = user.generate_auth_token
    else
      msg = { 'status code' => user }
    end
    render :json => msg
  end

  def reset_password
    msg = {'status code' => User.reset_password(params[:username])}
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
      if params[:message] == nil || params[:message].length < 256
        msg = { 'status code' => User.follow_request(params[:username], user, params[:message])}
      else
        msg = { 'status code' => -2 }
      end
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

  def get_directions(lat1, long1, lat2, long2)
    uri = URI('http://maps.googleapis.com/maps/api/directions/json')
    params = {:origin => '%f,%f'%[lat1,long1], :destination => '%f,%f'%[lat2,long2], :sensor => 'false', :mode => 'driving', :alternatives => 'true'}
    uri.query = URI.encode_www_form(params)
    
    res = Net::HTTP.get_response(uri)
    return res.body if res.is_a?(Net::HTTPSuccess)
  end

  def follow
    user = User.validate_user_cookie(session[:auth_token])
    if user.is_a? User
      location = User.follow(params[:username], user)
      if location.is_a? Position
        if user.update_position(params[:update], location)
          msg = { 'status code' => 2 , 'latitude' => location.latitude, 'longitude' => location.longitude, 'directions' => get_directions(location.latitude, location.longitude, user.positions.first.latitude, user.positions.first.longitude)}
        else
          msg = { 'status code' => 1 , 'latitude' => location.latitude, 'longitude' => location.longitude}
        end
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

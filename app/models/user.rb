class User < ActiveRecord::Base
  serialize :locations, Array
  has_secure_password
  has_many :positions
  has_many :followers, dependent: :destroy
  has_many :follow_requests, dependent: :destroy
  has_many :recently_followeds, -> { order("created_at DESC").limit(10) }, dependent: :destroy
  has_one :current_destination, :class_name => "Position"
  has_one :current_origin, :class_name => "Position"

  def self.validate_user(username, password)
    @user = User.find_by(username: username)
    if @user == nil
      return -1
    end
    if !@user.authenticate(password)
      return -2
    else
      return @user
    end
  end

  def self.validate_user_cookie(auth_token)
    @user = User.find_by(auth_token: auth_token)
    if @user == nil
      return -1
    else
      return @user
    end
  end

  def self.add(username, password)
    if username == '' or username.length > 128
      return -2
    end
    if password == '' or password.length > 128
      return -3
    end
    if User.find_by(username: username) == nil
      #puts 'found no such user'
      @user = User.new
      @user.username = username
      @user.password = password
      @user.password_confirmation = password
      @user.locations = []
      @user.broadcasting = false
      @user.save
      return @user
    else
      return -1
    end
  end

  def generate_auth_token
    token = Digest::SHA1.hexdigest("--%s--%s--" % [self.username, Time.now.asctime])
    self.auth_token = token
    self.save
    return token
  end

  def start_broadcast(latitude, longitude)
    self.positions.create(latitude: latitude, longitude: longitude, timestamp: Time.now)
    self.broadcasting = true
    self.save
  end

  def set_follower_position(latitude, longitude)
    if Follower.exists?(follower_id: self.id)
      self.positions.create(latitude: latitude, longitude: longitude, timestamp: Time.now)
      return true
    else
      return false
    end
  end

  def stop_broadcast
    self.broadcasting = false
    self.followers.clear
    self.follow_requests.clear
    self.save
  end

  # http://www.movable-type.co.uk/scripts/latlong.html
  # loc1 and loc2 are arrays of [latitude, longitude]
  def distance lat, lon
    lat1 = lat
    lon1 = lon
    lat2 = current_destination.latitude
    lon2 = current_destination.longitude
    dLat = (lat2-lat1) * Math::PI / 180;
    dLon = (lon2-lon1) * Math::PI / 180;
    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math::PI / 180) * Math.cos(lat2 * Math::PI / 180) *
      Math.sin(dLon/2) * Math.sin(dLon/2);
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    d = 6371 * c; # Multiply by 6371 to get Kilometers
  end

  def update_position(update, broadcaster_position)
    if self.positions.nil? || self.positions.first == nil
      return false
    elsif self.positions.first.timestamp < Time.now - 1800
      return false
    end
    puts update
    if update
      self.current_destination.create_current_destination(latitude: broadcaster_position.latitude, longitude: broadcaster_postion.longitude, timestamp: Time.now)
      self.current_origin.create_current_origin(latitude: self.positions.first.latitude, longitude: self.positions.first.longitude, timestamp: Time.now)
      return true
    elsif self.current_destination.nil? || self.current_origin.nil?
      self.current_destination.create_current_destination(latitude: broadcaster_position.latitude, longitude: broadcaster_postion.longitude, timestamp: Time.now)
      self.current_origin.create_current_origin(latitude: self.positions.first.latitude, longitude: self.positions.first.longitude, timestamp: Time.now)
      return true
    elsif self.current_destination.timestamp + 1800 < Time.now || self.current_origin.timestamp + 1800 < Time.now
      self.current_destination.create_current_destination(latitude: broadcaster_position.latitude, longitude: broadcaster_postion.longitude, timestamp: Time.now)
      self.current_origin.create_current_origin(latitude: self.positions.first.latitude, longitude: self.positions.first.longitude, timestamp: Time.now)
      return true
    elsif distance(self.positions.first.latitude, self.positions.first.longitude) < 0.1 * distance(current_origin.latitude, current_origin.longitude)
      self.current_destination.create_current_destination(latitude: broadcaster_position.latitude, longitude: broadcaster_postion.longitude, timestamp: Time.now)
      self.current_origin.create_current_origin(latitude: self.positions.first.latitude, longitude: self.positions.first.longitude, timestamp: Time.now)
      return true
    elsif distance(self.positions.first.latitude, self.positions.first.longitude) > 2 * distance(current_origin.latitude, current_origin.longitude)
      self.current_destination.create_current_destination(latitude: broadcaster_position.latitude, longitude: broadcaster_postion.longitude, timestamp: Time.now)
      self.current_origin.create_current_origin(latitude: self.positions.first.latitude, longitude: self.positions.first.longitude, timestamp: Time.now)
      return true
    else
      puts 'Hi'
      return false
    end
  end

  def self.follow(username, requester)
    @user = User.find_by(username: username)
    if @user == nil
      return -1
    end
    if @user.broadcasting
      if requester.check_permission(username) == 1
        if requester.recently_followeds.exists?(RecentlyFollowed.find_by(followed: @user.id, user_id: requester.id))
          requester.recently_followeds.destroy(RecentlyFollowed.find_by(followed: @user.id, user_id: requester.id))
        end
        requester.recently_followeds.create(followed: @user.id)
        return @user.positions.first
      else
        return -3
      end
    else
      return -2
    end
  end

  def self.follow_request(username, requester)
    @user = User.find_by(username: username)
    if @user == nil
      return -3
    end
    if @user.broadcasting
      @user.follow_requests.create(requester: requester.id)
      return 1
    else
      return -4
    end
  end

  def self.follow_cancellation(username, requester)
    @user = User.find_by(username: username)
    if @user == nil
      return -3
    end
    if @user.broadcasting
      if @user.follow_requests.exists?(FollowRequest.find_by(requester: requester.id, user_id: @user.id))
        @user.follow_requests.destroy(FollowRequest.find_by(requester: requester.id, user_id: @user.id))
      end
      if @user.followers.exists?(Follower.find_by(follower_id: requester.id, user_id: @user.id))
        @user.followers.destroy(Follower.find_by(follower_id: requester.id, user_id: @user.id))
      end
      return 1
    else
      return -4
    end
  end

  def invitation_response(username)
    @user = User.find_by(username: username)
    if !self.broadcasting
      return -3
    end
    if @user == nil
      return -4
    end
    self.followers.create(follower_id: @user.id)
    return 1
  end

  def check_permission(username)
    @user = User.find_by(username: username)
    if @user == nil
      return -4
    end
    if !@user.broadcasting
      return -3
    end
    if @user.followers.exists?(Follower.find_by(follower_id: self.id, user_id: @user.id))
      return 1
    else
      return 2
    end
  end

  def recently_followed
    list = []
    self.recently_followeds.each do |r|
      list << User.find(r.followed).username
    end
    return list
  end

  def check_requesters
    list = []
    self.follow_requests.each do |r|
      list << User.find(r.requester).username
      self.follow_requests.destroy(r)
    end
    return list
  end

  def follower_positions
    list = Hash.new
    self.followers.each do |r|
      user = User.find(r.follower_id)
      if !user.positions.nil?
        list[user.username] = [user.positions.first.latitude, user.positions.first.longitude]
      end
    end
    return list
  end

end

class User < ActiveRecord::Base
  serialize :locations, Array
  has_secure_password
  has_many :positions
  has_many :followers, dependent: :destroy
  has_many :follow_requests, dependent: :destroy

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

  def start_broadcast(latitude, longitude)
    @new_location = self.positions.create(latitude: latitude, longitude: longitude, timestamp: Time.now)
    self.broadcasting = true
    self.save
  end

  def stop_broadcast
    self.broadcasting = false
    self.followers.clear
    self.follow_requests.clear
    self.save
  end

  def self.follow(username, requester)
    @user = User.find_by(username: username)
    if @user == nil
      return -1
    end
    if @user.broadcasting
      if requester.check_permission(username) == 1
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
      if @user.follow_requests.exists?(FollowRequest.find_by(requester: requester.id))
        @user.follow_requests.destroy(FollowRequest.find_by(requester: requester.id))
      end
      if @user.followers.exists?(Follower.find_by(follower_id: requester.id))
        @user.followers.destroy(Follower.find_by(follower_id: requester.id))
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
    if @user.followers.exists?(Follower.find_by(follower_id: self.id))
      return 1
    else
      return 2
    end
  end

  def check_requesters
    list = []
    self.follow_requests.each do |r|
      list << User.find(r.requester).username
      self.follow_requests.destroy(r)
    end
    return list
  end

end

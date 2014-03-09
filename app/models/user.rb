class User < ActiveRecord::Base
  serialize :locations, Array

  def self.validate_user(username, password)
    @user = User.find_by(username: username)
    if @user == nil
      return -1
    end
    if @user.password != password
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
      puts 'found no such user'
      @user = User.new
      @user.username = username
      @user.password = password
      @user.locations = []
      @user.broadcasting = false
      @user.save
      return @user
    else
      return -1
    end
  end

  def start_broadcast(latitude, longitude)
    @new_location = [latitude, longitude]
    self.locations.push(@new_location)
    self.broadcasting = true
    self.save
  end

  def stop_broadcast
    self.broadcasting = false
    self.save
  end

  def self.follow(username)
    @user = User.find_by(username: username)
    if @user == nil
      return -1
    end
    if @user.broadcasting
      return @user.locations.last
    else
      return -2
    end
  end

end

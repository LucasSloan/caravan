require 'test_helper'

class UserTest < ActiveSupport::TestCase


    SUCCESS =             	 		1	# : a success
    ERR_CREATE_USER_EXISTS=			-1	# : the username exists, cannot create new user with that username
	ERR_CREATE_BAD_USERNAME=		-2	# : the proposed username is too long, too short, or contains an illegal character
	ERR_CREATE_BAD_PASSWORD=		-3	# : the proposed password is too long, too short, or contains an illegal character
	
	ERR_LOGIN_BAD_USERNAME=			-1	# : the username does not exist
	ERR_LOGIN_BAD_PASSWORD=			-2	# : the password is not the one that is associated with the username
	
	ERR_FOLLOW_BAD_USERNAME=		-1	# : an account with that username does not exist
	ERR_FOLLOW_NOT_BROADCASTING=	-2	# : an account with that username exists, but is not broadcasting 
	



  test "test good create" do
    #User.testAPI_resetFixture
	result = User.add("username0","password")
	assert((result.is_a? User), "valid add should return the new user")

	s = ""
	for i in 1..128
      s << "a"
    end
	result = User.add(s,"password")
	assert((result.is_a? User), "valid add should return the new user")
  end
 
  test "test create with invalid username" do
    #User.testAPI_resetFixture
	result = User.add("","password")
	assert(result ==ERR_CREATE_BAD_USERNAME,"empty username should not be accepted")
	
	s = ""
	for i in 1..129
      s << "b"
    end
	result = User.add(s,"password")
	assert(result ==ERR_CREATE_BAD_USERNAME,"too-long username should not be accepted")
  end
  
  test "test create with bad password" do
    #User.testAPI_resetFixture
	result = User.add("username1","")
	assert(result ==ERR_CREATE_BAD_PASSWORD,"empty password should not be accepted")
	
	s = ""
	for i in 1..129
      s << "b"
    end
	result = User.add("username2",s)
	assert(result ==ERR_CREATE_BAD_PASSWORD,"too-long password should not be accepted")
  end

  test "test create existent user" do
    #User.testAPI_resetFixture
	
	result = User.add("username3","password")
	assert((result.is_a? User), "valid add should return the new user")
	
	result = User.add("username3","password")
	assert(result == ERR_CREATE_USER_EXISTS, "trying to add an existing should result in error")
  end

  test "test validate_user with bad username" do
    #User.testAPI_resetFixture
	result = User.validate_user("not_user","password")
	assert(result ==ERR_LOGIN_BAD_USERNAME,"unregistered username should not be accepted")
  end

  test "test validate_user with bad password" do
    #User.testAPI_resetFixture
	result = User.add("username4","password")
	assert((result.is_a? User), "valid add should return the new user")
	
	result = User.validate_user("username4","not the password")
	assert(result ==ERR_LOGIN_BAD_PASSWORD,"username with wrong password should not be accepted")
  end
  
  test "test validate_user with valid user" do
    #User.testAPI_resetFixture
	result = User.add("username5","password")
	assert((result.is_a? User), "valid add should return the new user")
	
	result = User.validate_user("username5","password")
	assert((result.is_a? User),"registered user should not be validated")
  end
  
  test "test start_broadcast and stop_broadcast" do
    #User.testAPI_resetFixture
	result = User.add("username6","password")
	assert((result.is_a? User), "valid add should return the new user")
	
	result.start_broadcast(89.9,90.1)
	assert(result.broadcasting == true, "start_broadcast should make 'broadcasting' true")
	assert(result.locations != nil, "start_broadcast should put something in 'locations'")
	
	result.stop_broadcast
	assert(result.broadcasting == false, "stop_broadcast should make 'broadcasting' false")
	
	result.stop_broadcast
	assert(result.broadcasting == false, "calling stop_broadcast twice should not cause issues")
  end
  
  test "test follow non-existant user" do
    #User.testAPI_resetFixture
	result = User.follow("username8")
	assert(result ==ERR_FOLLOW_BAD_USERNAME,"cannot follow non-existant user")
  end
  
  test "test follow non-broadcasting user" do
    #User.testAPI_resetFixture
	other = User.add("username9","password")
	result = User.follow("username9")
	assert(result ==ERR_FOLLOW_NOT_BROADCASTING,"cannot follow non-broadcasting user")
  end  
  
  
  test "test follow broadcasting user" do
    #User.testAPI_resetFixture
	other = User.add("username11","password")
	other.start_broadcast(89.9,90.1)
	
	result = User.follow("username11")
	assert(result == other.positions.first,"can follow broadcasting user")
  end  

  test "test follow request" do
    broadcaster = User.add("username12","password")
    follower = User.add("username13","password")
    broadcaster.start_broadcast(0,0)
    assert(User.follow_request(broadcaster.username, follower) == 1, "Request failled")
    assert(broadcaster.follow_requests.size == 1, broadcaster.follow_requests.size)
    assert(broadcaster.follow_requests.first.requester == follower.id, "Incorrect requester id")
    follower2 = User.add("username14", "password")
    assert(User.follow_request(broadcaster.username, follower2) == 1, "Request failled")
    assert(broadcaster.follow_requests.size == 2, broadcaster.follow_requests.size)
    assert(broadcaster.follow_requests.first.requester == follower.id, "Incorrect requester id")
    assert(broadcaster.follow_requests.last.requester == follower2.id, "Incorrect requester id")
  end

  test "test follow cancellation" do
    broadcaster = User.add("username15","password")
    follower = User.add("username16","password")
    broadcaster.start_broadcast(0,0)
    assert(User.follow_request(broadcaster.username, follower) == 1, "Request failled")
    assert(broadcaster.follow_requests.size == 1, broadcaster.follow_requests.size)
    assert(broadcaster.follow_requests.first.requester == follower.id, "Incorrect requester id")
    follower2 = User.add("username17", "password")
    assert(User.follow_request(broadcaster.username, follower2) == 1, "Request failled")
    assert(broadcaster.follow_requests.size == 2, broadcaster.follow_requests.size)
    assert(broadcaster.follow_requests.first.requester == follower.id, "Incorrect requester id")
    assert(broadcaster.follow_requests.last.requester == follower2.id, "Incorrect requester id")
    assert(User.follow_cancellation(broadcaster.username, follower) == 1, "Cancellation failed")
    assert(broadcaster.follow_requests.size == 1, broadcaster.follow_requests.size)
    assert(broadcaster.follow_requests.first.requester == follower2.id, "Incorrect requester id")
  end
end

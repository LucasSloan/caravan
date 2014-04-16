require 'test_helper'
require 'securerandom'

class ApiControllerTest < ActionController::TestCase
  test "create_user user" do
    post(:create_user, {'username' => SecureRandom.hex, 'password' => "password"})
    assert_response(:success, {"status code"=>"1"})
    assert '{"status code":1}' == @response.body, @response.body
  end

  test "duplicate user" do
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body

    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body
  end

  test "bad username" do
    @username = ""
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body


    @username = "Rambles in Germany and Italy is a travel narrative by the British Romantic author Mary Shelley (pictured). Issued in 1844, it describes two European trips that she took with her son and some of his friends. She had lived in Italy with her husband, Percy Bysshe Shelley, between 1818 and 1823 and it was associated with joy and grief: she had written much there but had also lost her husband and two children. Shelley presented her material from what she describes as a political point of view, challenging the convention that it was improper for women to write about politics. Her aim was to arouse English sympathy for Italian revolutionaries, having associated herself with the movement when in Paris on her second trip. Although Shelley herself thought the work, it found favour with reviewers who praised its independence of thought, wit, and feeling, and her political commentary on Italy. However, for most of the 19th and 20th centuries, Shelley was usually known only for Frankenstein and her husband. Rambles was not reprinted until the rise of feminist literary criticism in the 1970s provoked a wider interest in her entire corpus."
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body
  end

  test "bad password" do 
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "Rambles in Germany and Italy is a travel narrative by the British Romantic author Mary Shelley (pictured). Issued in 1844, it describes two European trips that she took with her son and some of his friends. She had lived in Italy with her husband, Percy Bysshe Shelley, between 1818 and 1823 and it was associated with joy and grief: she had written much there but had also lost her husband and two children. Shelley presented her material from what she describes as a political point of view, challenging the convention that it was improper for women to write about politics. Her aim was to arouse English sympathy for Italian revolutionaries, having associated herself with the movement when in Paris on her second trip. Although Shelley herself thought the work, it found favour with reviewers who praised its independence of thought, wit, and feeling, and her political commentary on Italy. However, for most of the 19th and 20th centuries, Shelley was usually known only for Frankenstein and her husband. Rambles was not reprinted until the rise of feminist literary criticism in the 1970s provoked a wider interest in her entire corpus."})
    assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body
  end

  test "nonexistant user" do 
    @username = SecureRandom.hex
    post(:login, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body
  end
  
  test "incorrect password" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #try to login
    post(:login, {'username' => @username, 'password' => "not the password"})
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body
  end
  
  test "good login" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #try to login
    post(:login, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
  end


  test "broadcast bad username" do
    #broadcast
    @username = SecureRandom.hex
    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "122.34", 'longitude' => "12.34" })
    assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body
  end
  
  test "broadcast bad password" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #broadcast
    post(:broadcast, {'username' => @username, 'password' => "passwordpasswordpasswordpasswo32passwordpasswordpasswordpasswo64passwordpasswordpasswordpasswo32passwordpasswordpasswordpassw128passwordpasswordpasswordpasswo32passwordpasswordpasswordpasswo64passwordpasswordpasswordpasswo32passwordpasswordpasswordpassw256",
           'latitude' => "122.34", 'longitude' => "12.34" })
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body

    post(:broadcast, {'username' => @username, 'password' => "", 'latitude' => "122.34", 'longitude' => "12.34" })
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body

    post(:broadcast, {'username' => @username, 'password' => "not the password", 'latitude' => "122.34", 'longitude' => "12.34" })
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body
  end
  
  test "broadcast bad location" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #bad lat

    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "182.34", 'longitude' => "12.34" })
    assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body	
    #bad long
    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "12.34", 'longitude' => "192.34" })
    assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body	
    #bad lat
    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "-232.34", 'longitude' => "12.34" })
    assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body	
    #bad long
    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "12.34", 'longitude' => "-212.34" })
    assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body	
  end

  test "good broadcast" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #broadcast
    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
  end	

  test "stop broadcasting nonexistant user" do 
    @username = SecureRandom.hex
    post(:stop_broadcast, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body
  end
  
  test "stop broadcasting incorrect password" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #try to stop broadcasting
    post(:stop_broadcast, {'username' => @username, 'password' => "not the password"})
    assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body
  end
    
  test "stop broadcast" do
    #create account
    @username = SecureRandom.hex
    post(:create_user, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
    #broadcast
    post(:broadcast, {'username' => @username, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#follow
    get(:follow_request, {'myUsername' => @username, 'myPassword' =>"password", 'username' =>@username})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#stop broadcast
    post(:stop_broadcast, {'username' => @username, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#follow again
    get(:follow_request, {'myUsername' => @username, 'myPassword' =>"password", 'username' =>@username})
    assert_response(:success)
    assert '{"status code":-4}' == @response.body, @response.body	
  end	

  # FOLLOW REQUEST TESTS
  
  test "follow request with bad myUsername" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body
	
  end

  test "follow request with bad password" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"not_password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body
	
  end
  
  test "follow request with bad broadcaster username" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username})
	assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body
  end
  

  test "follow request with non-broadcasting broadcaster username" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":-4}' == @response.body, @response.body  
  end
  
  test "good follow request" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
  end
  
  
  
  # FOLLOW_CANCELLATION TESTS
  
  test "follow_cancellation with bad myUsername" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
	
	#follow cancellation
	post(:follow_cancellation, {'myUsername' => @username, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)	
	assert '{"status code":-1}' == @response.body, @response.body 
	
  end
  
  test "follow_cancellation with bad password" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
	
	#follow cancellation
	post(:follow_cancellation, {'myUsername' => @username1, 'myPassword' =>"not_password", 'username' =>@username2})
	assert_response(:success)	
	assert '{"status code":-2}' == @response.body, @response.body   
  end  
  
  test "follow_cancellation with bad broadcaster username" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
	
	#follow cancellation
	post(:follow_cancellation, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username})
	assert_response(:success)	
	assert '{"status code":-3}' == @response.body, @response.body   
  end  
  
  test "follow_cancellation with non-broadcasting broadcaster username" do #Is this one necessary? You won't get onto the 
																		   # requests list if the guy is not broadcasting. Or is this for if he stops before you cancel?
																			# Also, what if you are not following anyone when you use this?
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
	
	#stop broadcast
    post(:stop_broadcast, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	
	#follow cancellation
	post(:follow_cancellation, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)	
	assert '{"status code":-4}' == @response.body, @response.body																			
  end  
  
  test "good follow_cancellation" do
     @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	
	#follow request
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
	
	
	#follow cancellation
	post(:follow_cancellation, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)	
	assert '{"status code":1}' == @response.body, @response.body	 
  end


  # GET_FOLLOW_REQUEST TESTS
  
  test "get_follow_request with bad myUsername" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#get follow requests
	post(:check_requesters, {'myUsername' => @username, 'myPassword' =>"password"})
	assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body    
	 
  end
  
  test "get_follow_request with bad myPassword" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#get follow requests
	post(:check_requesters, {'myUsername' => @username1, 'myPassword' =>"not_password"})
	assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body      
  end

  test "get_follow_request with non-broadcasting myUsername" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#get follow requests
	post(:check_requesters, {'myUsername' => @username1, 'myPassword' =>"password"})
	assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body     
  end

  test "good get_follow_request" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#get follow requests when there are none
	post(:check_requesters, {'myUsername' => @username2, 'myPassword' =>"password"})
	assert_response(:success)
    assert '{"status code":1,"follow requests":[]}' == @response.body, @response.body   #Will cause an error; the API doesn't specify the name of the list to be returned; please change this line after you write the method.

	
	#follow request from account1
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body    
		
	
	
	#get follow requests when there is one
	post(:check_requesters, {'myUsername' => @username2, 'myPassword' =>"password"})
	assert_response(:success)
    assert '{"status code":1,"follow requests":["%s"]}'%@username1 == @response.body, @response.body   #Will cause an error; the API doesn't specify the name of the list to be returned; please change this line after you write the method.
	
  end  
  
  
  # INVITATION_RESPONSE TESTS
 
  test "invitation response with bad myUsername" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   

	post(:invitation_response, {'myUsername' => @username, 'myPassword' =>"password", 'username' =>@username1})
	assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body   
  end  

  test "invitation response with bad password" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   

	#invitation response from account2
	post(:invitation_response, {'myUsername' => @username2, 'myPassword' =>"not_password", 'username' =>@username1})
	assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body     
  end  
 
  test "invitation response with non-broadcasting broadcaster user" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	

	#invitation response from account2
	post(:invitation_response, {'myUsername' => @username2, 'myPassword' =>"password", 'username' =>@username1})
	assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body      
  end   
  
  test "invitation response with bad follower username" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   

	#invitation response from account2
	post(:invitation_response, {'myUsername' => @username2, 'myPassword' =>"password", 'username' =>@username})
	assert_response(:success)
    assert '{"status code":-4}' == @response.body, @response.body     
  end  
  
  
  
  
  
  
  
  
  
  test "good invitation response" do 
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   

	#invitation response from account2
	post(:invitation_response, {'myUsername' => @username2, 'myPassword' =>"password", 'username' =>@username1})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body     
  end  
  
  
    
  
  # CHECK_PERMISSION TESTS
  
  test "good permission check" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   
	
	#check permission from account1 
	post(:check_permission, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":2}' == @response.body, @response.body   	
		

	#invitation response from account2
	post(:invitation_response, {'myUsername' => @username2, 'myPassword' =>"password", 'username' =>@username1})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body  

	#check permission from account1 (again)
	post(:check_permission, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body  	
  
  end
  
 
  test "check permission with bad myUsername" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   
	
	#check permission from account1 
	post(:check_permission, {'myUsername' => @username, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body   	
  end  

  test "check permission with bad password" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   
	
	#check permission from account1 
	post(:check_permission, {'myUsername' => @username1, 'myPassword' =>"not_password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body   	
		
  end  

  test "check permission with non-broadcasting broadcaster username" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body  

	#stop broadcasting from account2
    post(:stop_broadcast, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#check permission from account1 
	post(:check_permission, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body    
  end    
  
  test "check permission with bad broadcaster username" do
    @username = SecureRandom.hex
	#create account1
	@username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#create account2
	@username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	
	#broadcast from account 2
	post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" })
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body	
	
	#follow request from account1 
	post(:follow_request, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username2})
	assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body   
	
	#check permission from account1 
	post(:check_permission, {'myUsername' => @username1, 'myPassword' =>"password", 'username' =>@username})
	assert_response(:success)
    assert '{"status code":-4}' == @response.body, @response.body   	
		
  end  

  
  
  
  
  
  
  
  #FOLLOW TESTS START HERE, need editing
  
  test "follow with bad myUsername" do
	@username1 = SecureRandom.hex
	post(:follow, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 })
	assert_response(:success)
    assert '{"status code":-1}' == @response.body, @response.body
  end
  
  test "follow with bad myPassword" do
	#create account1
    @username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#try to follow
	@username2 = SecureRandom.hex
    post(:follow, {'myUsername' => @username1,'myPassword' =>"not_the_password", 'username' =>@username2 })
	assert_response(:success)
    assert '{"status code":-2}' == @response.body, @response.body
  end  
  
  
  test "follow non-existent user" do
    #create account1
    @username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#try to follow
	@username2 = SecureRandom.hex
    post(:follow, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 })
	assert_response(:success)
    assert '{"status code":-3}' == @response.body, @response.body
	
  end
  
  test "follow non-broadcasting user" do
    #create account1
    @username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#create account2
    @username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
	#try to follow
	post(:follow, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 })
	assert_response(:success)
    assert '{"status code":-4}' == @response.body, @response.body
  end
  
  test "follow broadcasting user without access" do
  
  end
  
  
  
  test "good follow" do
    #create account1
    @username1 = SecureRandom.hex
    post(:create_user, {'username' => @username1, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    @token1 = @request.session[:auth_token]
    #create account2
    @username2 = SecureRandom.hex
    post(:create_user, {'username' => @username2, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    @token2 = @request.session[:auth_token]
    #create account3
    @username3 = SecureRandom.hex
    post(:create_user, {'username' => @username3, 'password' => "password"})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    @token3 = @request.session[:auth_token]
    #broadcast
    post(:broadcast, {'username' => @username2, 'password' => "password", 'latitude' => "22.34", 'longitude' => "32.54" }, {'auth_token' => @token2})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #submit follow_request
    post(:follow_request, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 }, {'auth_token' => @token1})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #submit follow_request
    post(:follow_request, {'myUsername' => @username3,'myPassword' =>"password", 'username' =>@username2 }, {'auth_token' => @token3})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #check permission before handshake
    post(:check_permission, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 }, {'auth_token' => @token1})
    assert_response(:success)
    assert '{"status code":2}' == @response.body, @response.body
    #fetch requester list
    post(:check_requesters, {'myUsername' => @username2,'myPassword' =>"password", }, {'auth_token' => @token2})
    assert_response(:success)
    assert '{"status code":1,"follow requests":["%s","%s"]}'%[@username1,@username3] == @response.body, @response.body
    #permit follow
    post(:invitation_response, {'myUsername' => @username2,'myPassword' =>"password", 'username' =>@username1 }, {'auth_token' => @token2})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #permit follow
    post(:invitation_response, {'myUsername' => @username2,'myPassword' =>"password", 'username' =>@username3 }, {'auth_token' => @token2})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #check permission after handshake
    post(:check_permission, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 }, {'auth_token' => @token1})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #check permission after handshake
    post(:check_permission, {'myUsername' => @username3,'myPassword' =>"password", 'username' =>@username2 }, {'auth_token' => @token3})
    assert_response(:success)
    assert '{"status code":1}' == @response.body, @response.body
    #try to follow
    post(:follow, {'myUsername' => @username1,'myPassword' =>"password", 'username' =>@username2 }, {'auth_token' => @token1})
    assert_response(:success)
    assert '{"status code":1,"latitude":22.34,"longitude":32.54}' == @response.body, @response.body
  end
end

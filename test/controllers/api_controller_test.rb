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
    
end

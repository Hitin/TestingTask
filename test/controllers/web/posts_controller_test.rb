require 'test_helper'

class Web::PostsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get new_post_url
    assert_response :success
  end
end

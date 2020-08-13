require 'test_helper'

class Web::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = create(:post)
    @headers = {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby',
    }
  end

  test 'should get index Posts without params' do
    get posts_path
    assert_response :success
  end

  test 'should get index Posts with params force' do
    response = { title: generate(:title), body: @post.body, userId: '1' }
    stub_request(:get, "#{Rails.configuration.external_api_url}/#{@post.id}").
      with(
        headers: @headers,
      ).
      to_return(status: 200, body: response.to_json, headers: {})
    get posts_path, params: { force: 'true' }
    assert_response :success
  end

  test 'should get show Posts without params' do
    get post_path(@post)
    assert_response :success
  end

  test 'should get show Posts with params' do
    response = { title: generate(:title), body: @post.body, userId: '1' }

    stub_request(:get, "#{Rails.configuration.external_api_url}/#{@post.id}").
      with(
        headers: @headers,
      ).
      to_return(status: 200, body: response.to_json, headers: {})
    get post_path(@post), params: { force: 'true' }
    assert_response :success
    @post.reload
    assert_equal response[:title], @post.title
  end

  test 'should get new' do
    get new_post_url
    assert_response :success
  end

  test 'should post create Post good request' do
    post_attrs = attributes_for(:post)
    post_attrs_service = post_attrs.clone
    post_attrs_service = CrudService.replace_key(post_attrs_service, :userId, :user_id)

    stub_http_request(:post, Rails.configuration.external_api_url).
      with(
        body: post_attrs_service.to_json,
        headers: @headers,
      ).
      to_return(status: 201, body: post_attrs_service.to_json, headers: {})
    post posts_path, params: { post: post_attrs }
    assert_response :redirect

    post_last = Post.last
    assert_equal post_attrs[:title], post_last.title
  end

  test 'should post create Post bad request' do
    post_attrs = attributes_for(:post)
    post_attrs_service = post_attrs.clone
    post_attrs_service = CrudService.replace_key(post_attrs_service, :userId, :user_id)

    stub_http_request(:post, Rails.configuration.external_api_url).
      with(
        body: post_attrs_service.to_json,
        headers: @headers,
      ).
      to_return(status: 404, body: post_attrs_service.to_json, headers: {})
    post posts_path, params: { post: post_attrs }
    assert_response :success

    post_find = Post.find_by(title: post_attrs[:title])
    assert_nil post_find
  end

  test 'should get edit Post' do
    get edit_post_path(@post)
    assert_response :success
  end

  test 'should put update Post' do
    attrs = {}
    attrs[:title] = generate(:title)
    uri = "#{Rails.configuration.external_api_url}/#{@post.id}"
    stub_http_request(:put, uri).
      with(
        body: attrs.to_json,
        headers: @headers,
      ).
      to_return(status: 200, body: attrs.to_json, headers: {})
    put post_path(@post), params: { post: attrs }
    assert_response :redirect

    @post.reload
    assert_equal attrs[:title], @post.title
  end

  test 'should delete destroy Post' do
    stub_request(:delete, "#{Rails.configuration.external_api_url}/#{@post.id}").
      with(
        headers: @headers,
      ).
      to_return(status: 200, body: "", headers: {})
    delete post_path(@post)
    assert_response :redirect

    assert_not Post.exists?(@post.id)
  end
end

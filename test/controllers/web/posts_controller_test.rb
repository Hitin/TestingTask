require 'test_helper'

class Web::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = create(:post)
  end

  test 'should get index Posts' do
    get posts_path
    assert_response :success
  end

  test 'should get show Posts' do
    get post_path(@post)
    assert_response :success
  end

  test 'should get new' do
    get new_post_url
    assert_response :success
  end

  test 'should post create Post good request' do
    post_attrs = attributes_for(:post)
    stub_http_request(:post, "http://jsonplaceholder.typicode.com/posts").
      with(
        body: post_attrs.to_json,
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/json; charset=UTF-8',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 201, body: post_attrs.to_json, headers: {})
    post posts_path, params: { post: post_attrs }
    assert_response :redirect

    post_last = Post.last
    assert_equal post_attrs[:title], post_last.title
  end

  test 'should post create Post bad request' do
    post_attrs = attributes_for(:post)
    p post_attrs.to_json
    stub_http_request(:post, "http://jsonplaceholder.typicode.com/posts").
      with(
        body: post_attrs.to_json,
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/json; charset=UTF-8',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 404, body: post_attrs.to_json, headers: {})
    post posts_path, params: { post: post_attrs }
    assert_response :success

    post_find = Post.find_by(title: post_attrs[:title])
    assert_nil post_find
  end

  test 'should delete destroy Post' do
    delete post_path(@post)
    assert_response :redirect

    assert_not Post.exists?(@post.id)
  end

  test 'should get edit Post' do
    get edit_post_path(@post)
    assert_response :success
  end

  test 'should put update Post' do
    attrs = {}
    attrs[:title] = generate(:title)

    put post_path(@post), params: { post: attrs }
    assert_response :redirect

    @post.reload
    assert_equal attrs[:title], @post.title
  end
end

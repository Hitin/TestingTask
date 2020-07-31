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

  test 'should post create Post' do
    post_attrs = attributes_for(:post)
    post posts_path, params: { post: post_attrs }
    assert_response :redirect

    post_last = Post.last
    assert_equal post_attrs[:title], post_last.title
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

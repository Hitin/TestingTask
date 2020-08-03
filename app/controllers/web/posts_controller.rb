class Web::PostsController < ApplicationController
  def index
    @posts = Post.all
    @errors = []
    @force = params[:force]
    arr = []
    if @force == 'true'
      @posts.each do |post|
        arr << force_update(post)
      end
      @posts = arr
    end
  end

  def show
    @force = params[:force]
    @errors = []
    @post = Post.find(params[:id])
    if @force == 'true'
      @post = force_update(@post)
    end
  end

  def new
    @post = Post.new
  end

  def create
    response = post_service('http://jsonplaceholder.typicode.com/posts', post_attrs)
    post_new = JSON.parse(response.body)
    @post = Post.new(post_new) 
    if response.code == '201'
      if @post.save
        redirect_to(posts_path)
      else
        render(action: :new)
      end
    else
      @errors = response.message 
      render(action: :new)
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_attrs)
      uri = "http://jsonplaceholder.typicode.com/posts/#{@post.id}"
      response = put_service( uri, post_attrs)
      if response.code != '200'
        @errors = response.message 
      end
      redirect_to(post_path(@post))
    else
      render(action: :edit)
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    uri = "http://jsonplaceholder.typicode.com/posts/#{@post.id}"
    response = delete_service(uri)
    redirect_to(posts_path)
  end

  private

  def force_update(post)
    uri = "http://jsonplaceholder.typicode.com/posts/#{post.id}"
    response = get_service(uri)
    if response.code == '200'
      post.update(JSON.parse(response.body))
    else
      @errors << response.message
    end
    return post
  end

  def delete_service(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host)
    req = Net::HTTP::Delete.new(uri.path)
    res = http.request(req)
    return res
  end

  def get_service(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host)
    req = Net::HTTP::Get.new(uri.path)
    res = http.request(req)
    return res
  end

  def post_service(url, attrs)
    uri = URI(url)
    http = Net::HTTP.new(uri.host)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json; charset=UTF-8'})
    req.body = attrs.to_json
    res = http.request(req)
    return res
  end

  def put_service(url, attrs)
    uri = URI(url)
    http = Net::HTTP.new(uri.host)
    req = Net::HTTP::Put.new(uri.path, {'Content-Type' =>'application/json; charset=UTF-8'})
    req.body = attrs.to_json
    res = http.request(req)
    return res
  end

  def post_attrs
    params.require(:post).permit(:title, :body, :userId)
  end
end

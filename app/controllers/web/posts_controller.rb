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
    @errors = []
    response = change_service('http://jsonplaceholder.typicode.com/posts', post_attrs, 'Post')
    post_new = JSON.parse(response.body)
    @post = Post.new(post_new)
    if response.code == '201'
      if @post.save
        redirect_to(posts_path)
      else
        render(action: :new)
      end
    else
      @errors << "Id #{@post.id} - #{response.message}"
      render(action: :new)
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    @errors = []
    if @post.update(post_attrs)
      uri = "http://jsonplaceholder.typicode.com/posts/#{@post.id}"
      response = change_service(uri, post_attrs, 'Put')
      if response.code != '200'
        @errors << "Id #{@post.id} - #{response.message}"
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
    service(uri, 'Delete')
    redirect_to(posts_path)
  end

  private

  def force_update(post)
    uri = "http://jsonplaceholder.typicode.com/posts/#{post.id}"
    response = service(uri, 'Get')
    if response.code == '200'
      post.update(JSON.parse(response.body))
    else
      @errors << "Id #{post.id} - #{response.message}"
    end
    post
  end

  def service(url, method)
    uri = URI(url)
    http = Net::HTTP.new(uri.host)
    method = "Net::HTTP::#{method}".constantize
    req = method.new(uri.path)
    res = http.request(req)
    res
  end

  def change_service(url, attrs, method)
    uri = URI(url)
    headers = { 'Content-Type' => 'application/json; charset=UTF-8' }
    http = Net::HTTP.new(uri.host)
    method = "Net::HTTP::#{method}".constantize
    req = method.new(uri.path, headers)
    req.body = attrs.to_json
    res = http.request(req)
    res
  end

  def post_attrs
    params.require(:post).permit(:title, :body, :userId)
  end
end

class Web::PostsController < ApplicationController
  def initialize
    @errors = []
  end

  def index
    @posts = Post.all
    arr = []
    if params[:force] == 'true'
      @posts.find_each do |post|
        arr << force_update(post)
      end
      @posts = arr
    end
  end

  def show
    @post = Post.find(params[:id])
    if params[:force] == 'true'
      @post = force_update(@post)
    end
  end

  def new
    @post = Post.new
  end

  def create
    attrs = replace_key(post_attrs, 'userId', 'user_id')
    response = ExternalService.change_service(Rails.configuration.external_api_url, attrs, 'Post')
    post_new = replace_key(JSON.parse(response.body), 'user_id', 'userId')
    @post = Post.new(post_new)
    if response.code == '201'
      if @post.save
        redirect_to(posts_path)
      else
        render(action: :new)
      end
    else
      add_errors(@post.id, response.message)
      render(action: :new)
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_attrs)
      uri = "#{Rails.configuration.external_api_url}/#{@post.id}"
      response = ExternalService.change_service(uri, post_attrs, 'Put')
      if response.code != '200'
        add_errors(@post.id, response.message)
      end
      redirect_to(post_path(@post))
    else
      render(action: :edit)
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    uri = "#{Rails.configuration.external_api_url}/#{@post.id}"
    ExternalService.service(uri, 'Delete')
    redirect_to(posts_path)
  end

  private

  def force_update(post)
    uri = "#{Rails.configuration.external_api_url}/#{post.id}"
    response = ExternalService.service(uri, 'Get')
    if response.code == '200'
      post_new = replace_key(JSON.parse(response.body), 'user_id', 'userId')
      post.update(post_new)
    else
      add_errors(post.id, response.message)
    end
    post
  end

  

  def add_errors(id, message)
    @errors << "Id #{id} - #{message}"
  end

  def replace_key(hash, new, old)
    hash[new] = hash.delete old
    hash
  end

  def post_attrs
    params.require(:post).permit(:title, :body, :user_id, :userId)
  end
end

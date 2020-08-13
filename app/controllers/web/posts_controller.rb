class Web::PostsController < ApplicationController
  def initialize
    @errors = []
  end

  def index
    @posts = Post.all
    list_posts = []
    if params[:force] == 'true'
      @posts.find_each do |post|
        list_posts << force_update(post)
      end
      @posts = list_posts
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
    attrs = CrudService.replace_key(post_attrs, 'userId', 'user_id')
    response = CrudService.create_post(attrs)
    @post = Post.new(post_attrs)
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
      response = CrudService.update_post(post_attrs, @post.id)
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
    CrudService.delete_post(@post.id)
    redirect_to(posts_path)
  end

  private

  def force_update(post)
    response = CrudService.get_post(post.id)
    if response.code == '200'
      post_new = CrudService.replace_key(JSON.parse(response.body), 'user_id', 'userId')
      post.update(post_new)
    else
      add_errors(post.id, response.message)
    end
    post
  end

  def add_errors(id, message)
    @errors << "Id #{id} - #{message}"
  end

  def post_attrs
    params.require(:post).permit(:title, :body, :user_id)
  end
end

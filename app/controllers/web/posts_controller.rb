class Web::PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_attrs)

    if @post.save
      redirect_to(posts_path)
    else
      render(action: :new)
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    if @post.update(post_attrs)
      redirect_to(post_path(@post))
    else
      render(action: :edit)
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to(posts_path)
  end

  private

  def post_attrs
    params.require(:post).permit(:title, :body, :userid)
  end
end

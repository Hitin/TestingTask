class Web::PostsController < ApplicationController
  def new
    @post = Post.new
  end
end

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
      p 'aaaa' 
      p response.message
      p response.code
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

  def post_service(url, attrs)
    uri = URI(url)
    http = Net::HTTP.new(uri.host)
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json; charset=UTF-8'})
    req.body = attrs.to_json
    res = http.request(req)
    # puts "response #{res.body}"
    # puts res.code       # => '200'
    # puts res.message    # => 'OK'
    # puts res.class.name # => 'HTTPOK'
    # return JSON.parse(res.body)
    return res
  end

  def post_attrs
    params.require(:post).permit(:title, :body, :userId)
  end
end

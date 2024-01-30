class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.order(created_at: :desc)
  end

  def new
    @post = Post.new
  end

  def edit

  end

  def show
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to root_path
    else
      render :new
    end
  end

  def update

    if @post.update(post_params)
      redirect_to root_path
    else
      render :edit
    end

  end

  def destroy

    @post.destroy
    redirect_to root_path
  end


  private

  def set_post
    @post = Post.find(params[:id])

  end

  def post_params
    params.require(:post).permit(:title, :body, :tag_list)
  end
end

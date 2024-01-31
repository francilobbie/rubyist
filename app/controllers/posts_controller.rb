class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @posts = Post.order(created_at: :desc)

    if params[:query].present?
      @posts = Post.where(title: params[:query])
    end
  end

  def new
    @post = current_user.posts.build
  end

  def edit
    if @post.user != current_user
      redirect_to root_path
    end
  end

  def show
    # @comment = Comment.new
    # @comments = @post.comments.order(created_at: :desc)
  end

  def create
    @post = current_user.posts.build(post_params)
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
    params.require(:post).permit(:title, :body, :tag_list, :user_id)
  end
end

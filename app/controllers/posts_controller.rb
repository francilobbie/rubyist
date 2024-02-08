class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @posts = if params[:query].present?
               Post.global_search(params[:query])
             else
               Post.all.order(created_at: :desc)
             end

    if params[:ajax].present?
      render partial: 'posts/list', locals: { posts: @posts }
    else
      # Normal HTML response
    end

    respond_to do |format|
      format.html # for regular requests
      format.js { render partial: 'posts/list', locals: { posts: @posts }, content_type: 'text/html' } # for AJAX requests
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
    @comments = @post.comments.order(created_at: :desc)
    @comment = Comment.new
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

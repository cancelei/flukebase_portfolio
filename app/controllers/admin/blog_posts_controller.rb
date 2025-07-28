class Admin::BlogPostsController < Admin::BaseController
  before_action :set_blog_post, only: [ :show, :edit, :update, :destroy ]

  def index
    @blog_posts = BlogPost.order(created_at: :desc).page(params[:page]).per(20)
  end

  def show
    # Blog post is set by before_action
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)

    if @blog_post.save
      redirect_to admin_blog_post_path(@blog_post), notice: "Blog post was successfully created."
    else
      render :new
    end
  end

  def edit
    # Blog post is set by before_action
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_post_path(@blog_post), notice: "Blog post was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "Blog post was successfully deleted."
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :slug, :published, :published_at, :content)
  end
end

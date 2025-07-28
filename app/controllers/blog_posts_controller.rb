class BlogPostsController < ApplicationController
  before_action :set_blog_post, only: [ :show ]

  def index
    @blog_posts = BlogPost.published.recent.page(params[:page]).per(10)
  end

  def show
    # Blog post is set by before_action
  end

  private

  def set_blog_post
    @blog_post = BlogPost.published.find_by!(slug: params[:id])
  end
end

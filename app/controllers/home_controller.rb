class HomeController < ApplicationController
  def index
    @featured_projects = Project.published.limit(3)
    @recent_blog_posts = BlogPost.published.recent.limit(3)
  end
end

class Admin::DashboardController < Admin::BaseController
  def index
    @projects_count = Project.count
    @published_projects_count = Project.published.count
    @blog_posts_count = BlogPost.count
    @published_blog_posts_count = BlogPost.published.count
    @subscribers_count = Subscriber.count
    @cv_entries_count = CvEntry.count
    @chat_messages_count = ChatMessage.count

    @recent_projects = Project.order(created_at: :desc).limit(5)
    @recent_blog_posts = BlogPost.order(created_at: :desc).limit(5)
    @recent_subscribers = Subscriber.order(created_at: :desc).limit(5)
  end
end

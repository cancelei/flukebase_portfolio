class Admin::SubscribersController < Admin::BaseController
  before_action :set_subscriber, only: [ :show, :destroy ]

  def index
    @subscribers = Subscriber.order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
  end

  def destroy
    @subscriber.destroy
    redirect_to admin_subscribers_path, notice: "Subscriber was successfully removed."
  end

  private

  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end
end

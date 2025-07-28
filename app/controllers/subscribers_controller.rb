class SubscribersController < ApplicationController
  def create
    @subscriber = Subscriber.new(subscriber_params)

    if @subscriber.save
      # Send confirmation email (to be implemented)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("subscription_form", partial: "subscribers/success") }
        format.html { redirect_to root_path, notice: "Thank you for subscribing!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("subscription_form", partial: "subscribers/form", locals: { subscriber: @subscriber }) }
        format.html { redirect_to root_path, alert: @subscriber.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end

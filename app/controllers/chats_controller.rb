class ChatsController < ApplicationController
  def show
    @chat_messages = ChatMessage.order(created_at: :desc).limit(10).reverse
    @chat_message = ChatMessage.new
  end

  def create
    @chat_message = ChatMessage.new(chat_message_params)

    if @chat_message.question.present?
      # Generate AI response using CvChatResponder service
      response = CvChatResponder.call(question: @chat_message.question)
      @chat_message.answer = response

      if @chat_message.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to chat_path }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("chat_form", partial: "form", locals: { chat_message: @chat_message }) }
          format.html { render :show }
        end
      end
    else
      @chat_message.errors.add(:question, "can't be blank")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("chat_form", partial: "form", locals: { chat_message: @chat_message }) }
        format.html { render :show }
      end
    end
  end

  private

  def chat_message_params
    params.require(:chat_message).permit(:question)
  end
end

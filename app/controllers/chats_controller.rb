class ChatsController < ApplicationController
  before_action :ensure_session_id

  def show
    @chat_messages = session_chat_messages
    @chat_message = ChatMessage.new
    @personal_info = PersonalInfo.current
  end

  def create
    @chat_message = ChatMessage.new(chat_message_params)
    @chat_message.session_id = session[:chat_session_id]

    if @chat_message.question.present?
      # Generate AI response using enhanced CvChatResponder service
      response = CvChatResponder.call(
        question: @chat_message.question,
        session_id: session[:chat_session_id]
      )
      @chat_message.answer = response

      if @chat_message.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.append("chat_messages", partial: "chat_message", locals: { message: @chat_message }),
              turbo_stream.replace("chat_form", partial: "form", locals: { chat_message: ChatMessage.new })
            ]
          end
          format.html { redirect_to chat_path }
        end
      else
        # Set required instance variables when rendering show template
        @chat_messages = session_chat_messages
        @personal_info = PersonalInfo.current
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("chat_form", partial: "form", locals: { chat_message: @chat_message }) }
          format.html { render :show }
        end
      end
    else
      @chat_message.errors.add(:question, "can't be blank")
      # Set required instance variables when rendering show template
      @chat_messages = session_chat_messages
      @personal_info = PersonalInfo.current
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("chat_form", partial: "form", locals: { chat_message: @chat_message }) }
        format.html { render :show }
      end
    end
  end

  private

  def ensure_session_id
    session[:chat_session_id] ||= SecureRandom.uuid
  end

  def session_chat_messages
    ChatMessage.where(session_id: session[:chat_session_id])
                .or(ChatMessage.where(session_id: nil)) # Legacy messages
                .order(created_at: :desc)
                .limit(20)
                .reverse
  end

  def chat_message_params
    params.require(:chat_message).permit(:question)
  end
end

require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  def setup
    @chat_message = ChatMessage.new(
      question: "What is your experience with Ruby on Rails?",
      answer: "I have 5 years of experience with Ruby on Rails.",
      session_id: SecureRandom.uuid
    )
  end

  test "should be valid with valid attributes" do
    assert @chat_message.valid?
  end

  test "should be invalid without question" do
    @chat_message.question = nil
    assert_not @chat_message.valid?
    assert_includes @chat_message.errors[:question], "can't be blank"
  end

  test "should be valid without answer" do
    @chat_message.answer = nil
    assert @chat_message.valid?
  end

  test "should be valid without session_id" do
    @chat_message.session_id = nil
    assert @chat_message.valid?
  end

  test "should respond to question, answer, and session_id" do
    assert_respond_to @chat_message, :question
    assert_respond_to @chat_message, :answer
    assert_respond_to @chat_message, :session_id
  end

  test "should save with valid attributes" do
    assert_difference "ChatMessage.count", 1 do
      @chat_message.save
    end
  end

  test "should have timestamps" do
    @chat_message.save
    assert @chat_message.created_at
    assert @chat_message.updated_at
  end
end

require "test_helper"
require "minitest/mock"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Create a personal info record for the chat UI
    PersonalInfo.create(
      name: "Test User",
      title: "Software Developer",
      email: "test@example.com",
      summary: "Test summary"
    )

    # Set a test API key to enable OpenAI integration
    ENV["OPENAI_API_KEY"] = "test-api-key"
  end

  def teardown
    # Restore environment variable
    ENV.delete("OPENAI_API_KEY")
  end

  test "should get show" do
    get chat_path
    assert_response :success
  end

  test "should ensure session id is set" do
    get chat_path
    assert_not_nil session[:chat_session_id]
    assert session[:chat_session_id].is_a?(String)
  end

  test "should create chat message with valid question" do
    # Mock the CvChatResponder service to avoid OpenAI API calls
    CvChatResponder.stub :call, "I have 5 years of experience with Ruby." do
      assert_difference("ChatMessage.count", 1) do
        post chats_path, params: { chat_message: { question: "What is your experience with Ruby?" } }
      end
    end

    assert_response :redirect
    assert_redirected_to chat_path
  end

  test "should not create chat message without question" do
    assert_no_difference("ChatMessage.count") do
      post chats_path, params: { chat_message: { question: "" } }
    end

    assert_response :success
  end

  test "should handle turbo stream response" do
    # Mock the CvChatResponder service to avoid OpenAI API calls
    CvChatResponder.stub :call, "I have 5 years of experience with Ruby." do
      post chats_path(format: :turbo_stream), params: { chat_message: { question: "What is your experience with Ruby?" } }
    end

    assert_response :success
  end

  test "should display chat messages for session" do
    session_id = SecureRandom.uuid
    ChatMessage.create(question: "Test question", answer: "Test answer", session_id: session_id)

    # Simulate session
    get chat_path
    assert_response :success
  end
end

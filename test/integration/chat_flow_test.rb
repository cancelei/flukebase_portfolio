require "test_helper"
require "minitest/mock"

class ChatFlowTest < ActionDispatch::IntegrationTest
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

  test "chat flow with valid question" do
    # Mock the CvChatResponder service to avoid OpenAI API calls
    mock_instance = Minitest::Mock.new
    mock_instance.expect :call, "I have 5 years of experience with Ruby."

    CvChatResponder.stub :new, lambda { |**kwargs| mock_instance } do
      # Get the chat page
      get chat_path
      assert_response :success

      # Submit a question
      post chats_path, params: { chat_message: { question: "What is your experience with Ruby?" } }
      assert_response :redirect

      # Follow redirect
      follow_redirect!
      assert_response :success

      # Check that the question and answer are displayed
      assert_select "div.chat-message", count: 1
      assert_select "div.chat-message div.bg-blue-600 p", text: "What is your experience with Ruby?"
      assert_select "div.chat-message div.bg-gray-100 div.prose", text: /I have 5 years of experience with Ruby\./
    end

    # Verify mock expectations
    assert_mock mock_instance
  end

  test "chat flow with turbo stream response" do
    # Mock the CvChatResponder service to avoid OpenAI API calls
    mock_instance = Minitest::Mock.new
    mock_instance.expect :call, "I have 5 years of experience with Ruby."

    CvChatResponder.stub :new, lambda { |**kwargs| mock_instance } do
      # Submit a question with turbo stream format
      post chats_path(format: :turbo_stream), params: { chat_message: { question: "What is your experience with Ruby?" } }
      assert_response :success

      # Check that the response contains turbo stream elements
      assert_match /turbo-stream/, response.body
      assert_match /chat_messages/, response.body
    end

    # Verify mock expectations
    assert_mock mock_instance
  end

  test "chat history is displayed" do
    # Create a chat message with nil session_id to match legacy handling
    ChatMessage.create(
      question: "Previous question",
      answer: "Previous answer",
      session_id: nil
    )

    get chat_path
    assert_response :success

    # Check that the previous chat message is displayed
    assert_select "div.chat-message", count: 1
    assert_select "div.chat-message div.bg-blue-600 p", text: "Previous question"
    assert_select "div.chat-message div.bg-gray-100 div.prose", text: /Previous answer/
  end
end

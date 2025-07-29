require "application_system_test_case"

class ChatsTest < ApplicationSystemTestCase
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

  test "visiting the chat page" do
    visit chat_path

    assert_selector "h1", text: "Chat with Test User"
    assert_selector "form"
  end

  test "submitting a question and receiving an answer" do
    # Mock the CvChatResponder service to avoid OpenAI API calls
    CvChatResponder.stub :call, "I have 5 years of experience with Ruby." do
      visit chat_path

      fill_in "chat_message_question", with: "What is your experience with Ruby?"
      click_on "Send"

      assert_text "What is your experience with Ruby?"
      assert_text "I have 5 years of experience with Ruby."
    end
  end

  test "chat history is displayed" do
    session_id = SecureRandom.uuid

    # Create a chat message
    ChatMessage.create(
      question: "Previous question",
      answer: "Previous answer",
      session_id: session_id
    )

    # Simulate session
    page.set_rack_session(chat_session_id: session_id)

    visit chat_path

    assert_text "Previous question"
    assert_text "Previous answer"
  end
end

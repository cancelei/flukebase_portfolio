class CvChatResponder
  def self.call(question:)
    new(question: question).call
  end

  def initialize(question:)
    @question = question
  end

  def call
    # Get CV entries for context
    cv_context = CvEntry.ordered.map { |entry| "#{entry.title}: #{entry.content}" }.join("\n\n")

    # Check if OpenAI is configured
    if ENV["OPENAI_API_KEY"].present?
      openai_response
    else
      fallback_response
    end
  rescue => e
    Rails.logger.error "CvChatResponder error: #{e.message}"
    "I'm sorry, I'm having trouble processing your question right now. Please try again later."
  end

  private

  def openai_response
    require "openai"

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = build_prompt

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "You are a helpful assistant answering questions about someone's CV/resume. Be professional and concise."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 300,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content") || fallback_response
  end

  def fallback_response
    # Simple keyword matching fallback
    question_lower = @question.downcase
    cv_entries = CvEntry.ordered

    # Look for relevant CV entries based on keywords
    relevant_entries = cv_entries.select do |entry|
      entry.title.downcase.include?(question_lower) ||
      entry.content.downcase.include?(question_lower)
    end

    if relevant_entries.any?
      "Based on the CV, here's what I found: #{relevant_entries.first.content.truncate(200)}"
    else
      "I'd be happy to help you learn more about this person's background. You can ask about their experience, skills, education, or projects."
    end
  end

  def build_prompt
    cv_context = CvEntry.ordered.map { |entry| "#{entry.title}: #{entry.content}" }.join("\n\n")

    <<~PROMPT
      Based on the following CV information, please answer this question: #{@question}

      CV Information:
      #{cv_context}

      Please provide a helpful and accurate response based only on the information provided in the CV.
    PROMPT
  end
end

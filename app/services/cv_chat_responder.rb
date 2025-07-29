class CvChatResponder
  def self.call(question:, session_id: nil)
    new(question: question, session_id: session_id).call
  end

  def initialize(question:, session_id: nil)
    @question = question
    @session_id = session_id
  end

  def call
    # Check if OpenAI is configured
    return fallback_response unless ENV["OPENAI_API_KEY"].present?

    begin
      # Generate embedding for the question
      question_embedding = generate_question_embedding(@question)
      return fallback_response unless question_embedding

      # Find relevant knowledge using vector similarity
      relevant_knowledge = KnowledgeItem.find_similar(question_embedding, limit: 5, threshold: 0.2)

      # Generate AI response with context
      openai_response_with_context(relevant_knowledge)
    rescue => e
      Rails.logger.error "CvChatResponder error: #{e.message}"
      "I'm sorry, I'm having trouble processing your question right now. Please try again later."
    end
  end

  private

  def generate_question_embedding(question)
    return nil if question.blank?

    begin
      require "openai"

      client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

      response = client.embeddings(
        parameters: {
          model: "text-embedding-3-small",
          input: question.truncate(8000)
        }
      )

      response.dig("data", 0, "embedding")
    rescue => e
      Rails.logger.error "Question embedding error: #{e.message}"
      nil
    end
  end

  def openai_response_with_context(knowledge_items)
    require "openai"

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    # Build context from relevant knowledge
    context = build_context_from_knowledge(knowledge_items)

    # Create specialized system prompt for recruitment scenarios
    system_prompt = build_recruitment_system_prompt

    prompt = build_contextualized_prompt(context)

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: system_prompt
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 500,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content") || fallback_response
  end

  def build_recruitment_system_prompt
    personal_info = PersonalInfo.current
    candidate_name = personal_info.name.presence || "the candidate"

    <<~PROMPT
      You are an AI assistant helping recruiters and potential employers learn about #{candidate_name}, a professional software developer.#{' '}

      Your role is to:
      - Answer questions about #{candidate_name}'s professional background, skills, experience, and qualifications
      - Help recruiters assess if #{candidate_name} is a good fit for their projects (full-time, part-time, or freelance)
      - Provide specific, accurate information based on the provided context
      - Be professional, concise, and helpful
      - Focus on technical skills, work experience, education, and project accomplishments
      - If asked about availability or specific arrangements, suggest contacting #{candidate_name} directly

      Key guidelines:
      - Only use information provided in the context
      - Be honest about what information is available
      - Highlight relevant experience and skills for the type of role being discussed
      - Suggest specific examples from projects or work experience when relevant
      - If information isn't available, say so and suggest what other information might be helpful

      Remember: Your goal is to help recruiters make informed decisions about whether #{candidate_name} would be a good fit for their specific needs.
    PROMPT
  end

  def build_context_from_knowledge(knowledge_items)
    return "No specific information available." if knowledge_items.empty?

    context_parts = knowledge_items.map do |item|
      "#{item.title}: #{item.content}"
    end

    context_parts.join("\n\n")
  end

  def build_contextualized_prompt(context)
    <<~PROMPT
      Based on the following information about the candidate:

      #{context}

      Please answer this question: #{@question}

      Provide a helpful, professional response that would assist a recruiter in understanding whether this candidate would be a good fit for their project or role. Focus on relevant skills, experience, and qualifications.
    PROMPT
  end

  def fallback_response
    # Enhanced fallback with knowledge base search
    relevant_items = search_knowledge_by_keywords(@question)

    if relevant_items.any?
      item = relevant_items.first
      <<~RESPONSE
        Based on the available information: #{item.content.truncate(300)}

        I'd be happy to provide more specific details about experience, skills, education, projects, or availability. What would you like to know more about?
      RESPONSE
    else
      personal_info = PersonalInfo.current
      candidate_name = personal_info.name.presence || "this candidate"

      <<~RESPONSE
        I'm here to help you learn about #{candidate_name}'s professional background and qualifications.

        You can ask me about:
        • Work experience and technical skills
        • Education and certifications#{'  '}
        • Previous projects and accomplishments
        • Programming languages and technologies
        • Availability for full-time, part-time, or freelance work

        What specific information would be most helpful for your recruiting needs?
      RESPONSE
    end
  end

  def search_knowledge_by_keywords(question)
    keywords = extract_keywords(question.downcase)
    return [] if keywords.empty?

    KnowledgeItem.where(
      keywords.map { |keyword|
        "LOWER(title) LIKE ? OR LOWER(content) LIKE ?"
      }.join(" OR "),
      *keywords.flat_map { |keyword| [ "%#{keyword}%", "%#{keyword}%" ] }
    ).limit(3)
  end

  def extract_keywords(question)
    # Extract relevant keywords for job/recruitment context
    recruitment_keywords = %w[
      experience work job role position
      skills technical programming languages
      education degree university college
      certification certified
      project projects portfolio
      available availability freelance full-time part-time
      ruby rails javascript react python
      backend frontend fullstack full-stack
      database sql postgresql mysql
      aws cloud deployment
      years senior junior lead
      startup enterprise
    ]

    words = question.split(/\W+/).reject(&:blank?)
    words.select { |word| word.length > 2 }.first(5) +
    (words & recruitment_keywords)
  end
end

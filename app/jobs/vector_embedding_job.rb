class VectorEmbeddingJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(knowledge_item_id)
    knowledge_item = KnowledgeItem.find_by(id: knowledge_item_id)
    return unless knowledge_item

    # Generate embedding using OpenAI
    embedding = generate_embedding(knowledge_item.content)

    if embedding
      knowledge_item.update!(embedding_vector: embedding)
      Rails.logger.info "Generated embedding for KnowledgeItem #{knowledge_item.id}: #{knowledge_item.title}"
    else
      Rails.logger.error "Failed to generate embedding for KnowledgeItem #{knowledge_item.id}"
    end
  end

  private

  def generate_embedding(text)
    return nil if text.blank? || ENV["OPENAI_API_KEY"].blank?

    begin
      require "openai"

      client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

      response = client.embeddings(
        parameters: {
          model: "text-embedding-3-small",
          input: text.truncate(8000) # Stay within token limits
        }
      )

      embedding_data = response.dig("data", 0, "embedding")
      return embedding_data if embedding_data.is_a?(Array)

      Rails.logger.error "Invalid embedding response format: #{response}"
      nil
    rescue => e
      Rails.logger.error "OpenAI embedding error: #{e.message}"
      nil
    end
  end
end

require "matrix"
require "json"

class KnowledgeItem < ApplicationRecord
  validates :content_type, presence: true
  validates :title, presence: true
  validates :content, presence: true

  scope :by_type, ->(type) { where(content_type: type) }

  # Calculate cosine similarity between two embedding vectors
  def self.cosine_similarity(vec1, vec2)
    return 0.0 if vec1.empty? || vec2.empty? || vec1.length != vec2.length

    dot_product = vec1.zip(vec2).map { |a, b| a * b }.sum
    magnitude1 = Math.sqrt(vec1.map { |x| x * x }.sum)
    magnitude2 = Math.sqrt(vec2.map { |x| x * x }.sum)

    return 0.0 if magnitude1 == 0 || magnitude2 == 0

    dot_product / (magnitude1 * magnitude2)
  end

  # Find similar knowledge items using vector similarity
  def self.find_similar(query_embedding, limit: 5, threshold: 0.1)
    return [] if query_embedding.blank?

    items_with_similarity = []

    where.not(embedding: nil).find_each do |item|
      begin
        item_embedding = JSON.parse(item.embedding)
        similarity = cosine_similarity(query_embedding, item_embedding)

        if similarity > threshold
          items_with_similarity << {
            item: item,
            similarity: similarity
          }
        end
      rescue JSON::ParserError => e
        Rails.logger.warn "Failed to parse embedding for KnowledgeItem #{item.id}: #{e.message}"
        next
      end
    end

    # Sort by similarity (highest first) and take the limit
    items_with_similarity
      .sort_by { |entry| -entry[:similarity] }
      .first(limit)
      .map { |entry| entry[:item] }
  end

  # Get embedding as parsed array
  def embedding_vector
    return [] if embedding.blank?

    begin
      JSON.parse(embedding)
    rescue JSON::ParserError
      []
    end
  end

  # Set embedding from array
  def embedding_vector=(vector)
    self.embedding = vector.to_json
  end

  # Generate a comprehensive knowledge base from all professional content
  def self.rebuild_from_content!
    transaction do
      # Clear existing knowledge items
      delete_all

      # Add personal information
      personal_info = PersonalInfo.current
      if personal_info.persisted?
        create_from_content(
          content_type: "PersonalInfo",
          content_id: personal_info.id,
          title: "#{personal_info.name} - #{personal_info.title}",
          content: build_personal_info_content(personal_info)
        )
      end

      # Add work experiences
      CvEntry.experiences.find_each do |entry|
        create_from_content(
          content_type: "CvEntry",
          content_id: entry.id,
          title: "Work Experience: #{entry.title}",
          content: build_experience_content(entry)
        )
      end

      # Add education records
      Education.ordered.find_each do |education|
        create_from_content(
          content_type: "Education",
          content_id: education.id,
          title: "Education: #{education.full_degree}",
          content: build_education_content(education)
        )
      end

      # Add skills by category
      Skill::CATEGORIES.each do |category|
        skills = Skill.by_category(category)
        next if skills.empty?

        create_from_content(
          content_type: "Skills",
          content_id: 0, # Virtual ID for grouped content
          title: "Skills: #{category}",
          content: build_skills_content(category, skills)
        )
      end

      # Add certifications
      Certification.active.find_each do |cert|
        create_from_content(
          content_type: "Certification",
          content_id: cert.id,
          title: "Certification: #{cert.name}",
          content: build_certification_content(cert)
        )
      end

      # Add projects
      Project.published.find_each do |project|
        create_from_content(
          content_type: "Project",
          content_id: project.id,
          title: "Project: #{project.title}",
          content: build_project_content(project)
        )
      end

      # Add blog posts
      BlogPost.published.find_each do |post|
        create_from_content(
          content_type: "BlogPost",
          content_id: post.id,
          title: "Blog Post: #{post.title}",
          content: build_blog_content(post)
        )
      end
    end

    Rails.logger.info "Knowledge base rebuilt with #{count} items"
  end

  private

  def self.create_from_content(content_type:, content_id:, title:, content:)
    knowledge_item = create!(
      content_type: content_type,
      content_id: content_id,
      title: title,
      content: content
    )

    # Generate embedding in background
    VectorEmbeddingJob.perform_later(knowledge_item.id)

    knowledge_item
  end

  def self.build_personal_info_content(info)
    content_parts = []
    content_parts << "Name: #{info.name}" if info.name.present?
    content_parts << "Professional Title: #{info.title}" if info.title.present?
    content_parts << "Location: #{info.location}" if info.location.present?
    content_parts << "Contact: #{info.email}" if info.email.present?
    content_parts << "Summary: #{info.summary.to_plain_text}" if info.summary.present?

    # Add social links
    info.social_links.each do |link|
      content_parts << "#{link[:name]}: #{link[:url]}"
    end

    content_parts.join(". ")
  end

  def self.build_experience_content(entry)
    content_parts = []
    content_parts << "Position: #{entry.title}"
    content_parts << "Company: #{entry.company}" if entry.company.present?
    content_parts << "Location: #{entry.location}" if entry.location.present?
    content_parts << "Duration: #{entry.date_range}" if entry.date_range.present?
    content_parts << "Description: #{entry.content.to_plain_text}"

    content_parts.join(". ")
  end

  def self.build_education_content(education)
    content_parts = []
    content_parts << "Degree: #{education.full_degree}"
    content_parts << "Institution: #{education.institution}"
    content_parts << "Duration: #{education.date_range}"
    content_parts << "GPA: #{education.gpa}" if education.gpa.present?
    content_parts << "Achievements: #{education.achievements.to_plain_text}" if education.achievements.present?

    content_parts.join(". ")
  end

  def self.build_skills_content(category, skills)
    content_parts = [ "Skills in #{category}:" ]

    skills.each do |skill|
      content_parts << "#{skill.name} (#{skill.proficiency_name} level)"
    end

    content_parts.join(" ")
  end

  def self.build_certification_content(cert)
    content_parts = []
    content_parts << "Certification: #{cert.name}"
    content_parts << "Issuer: #{cert.issuer}"
    content_parts << "Date: #{cert.date_range}"
    content_parts << "Status: #{cert.expiry_status}"
    content_parts << "Credential ID: #{cert.credential_id}" if cert.credential_id.present?

    content_parts.join(". ")
  end

  def self.build_project_content(project)
    content_parts = []
    content_parts << "Project: #{project.title}"
    content_parts << "Description: #{project.description.to_plain_text}"
    content_parts << "Technologies: #{project.tags.pluck(:name).join(', ')}" if project.tags.any?
    content_parts << "GitHub: #{project.github_url}" if project.github_url.present?
    content_parts << "Demo: #{project.demo_url}" if project.demo_url.present?

    content_parts.join(". ")
  end

  def self.build_blog_content(post)
    content_parts = []
    content_parts << "Blog Post: #{post.title}"
    content_parts << "Content: #{post.content.to_plain_text}"
    content_parts << "Published: #{post.published_at.strftime('%B %Y')}" if post.published_at

    content_parts.join(". ")
  end
end

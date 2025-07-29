class KnowledgeBaseUpdateJob < ApplicationJob
  queue_as :default

  def perform(content_type, content_id, action = "update")
    case action
    when "delete"
      handle_content_deletion(content_type, content_id)
    else
      handle_content_update(content_type, content_id)
    end
  end

  private

  def handle_content_deletion(content_type, content_id)
    KnowledgeItem.where(
      content_type: content_type,
      content_id: content_id
    ).destroy_all

    Rails.logger.info "Deleted knowledge items for #{content_type}##{content_id}"
  end

  def handle_content_update(content_type, content_id)
    # Find the actual content record
    content_record = find_content_record(content_type, content_id)
    return unless content_record

    # Delete existing knowledge items for this content
    handle_content_deletion(content_type, content_id)

    # Create new knowledge item based on content type
    case content_type
    when "PersonalInfo"
      create_personal_info_knowledge(content_record)
    when "CvEntry"
      create_cv_entry_knowledge(content_record) if content_record.entry_type == "experience"
    when "Education"
      create_education_knowledge(content_record)
    when "Certification"
      create_certification_knowledge(content_record)
    when "Project"
      create_project_knowledge(content_record) if content_record.published?
    when "BlogPost"
      create_blog_post_knowledge(content_record) if content_record.published?
    when "Skills"
      # Special case - rebuild all skills knowledge
      rebuild_skills_knowledge
    end
  end

  def find_content_record(content_type, content_id)
    case content_type
    when "PersonalInfo"
      PersonalInfo.find_by(id: content_id)
    when "CvEntry"
      CvEntry.find_by(id: content_id)
    when "Education"
      Education.find_by(id: content_id)
    when "Certification"
      Certification.find_by(id: content_id)
    when "Project"
      Project.find_by(id: content_id)
    when "BlogPost"
      BlogPost.find_by(id: content_id)
    end
  end

  def create_personal_info_knowledge(personal_info)
    KnowledgeItem.create!(
      content_type: "PersonalInfo",
      content_id: personal_info.id,
      title: "#{personal_info.name} - #{personal_info.title}",
      content: KnowledgeItem.send(:build_personal_info_content, personal_info)
    ).tap do |item|
      VectorEmbeddingJob.perform_later(item.id)
    end
  end

  def create_cv_entry_knowledge(entry)
    KnowledgeItem.create!(
      content_type: "CvEntry",
      content_id: entry.id,
      title: "Work Experience: #{entry.title}",
      content: KnowledgeItem.send(:build_experience_content, entry)
    ).tap do |item|
      VectorEmbeddingJob.perform_later(item.id)
    end
  end

  def create_education_knowledge(education)
    KnowledgeItem.create!(
      content_type: "Education",
      content_id: education.id,
      title: "Education: #{education.full_degree}",
      content: KnowledgeItem.send(:build_education_content, education)
    ).tap do |item|
      VectorEmbeddingJob.perform_later(item.id)
    end
  end

  def create_certification_knowledge(cert)
    KnowledgeItem.create!(
      content_type: "Certification",
      content_id: cert.id,
      title: "Certification: #{cert.name}",
      content: KnowledgeItem.send(:build_certification_content, cert)
    ).tap do |item|
      VectorEmbeddingJob.perform_later(item.id)
    end
  end

  def create_project_knowledge(project)
    KnowledgeItem.create!(
      content_type: "Project",
      content_id: project.id,
      title: "Project: #{project.title}",
      content: KnowledgeItem.send(:build_project_content, project)
    ).tap do |item|
      VectorEmbeddingJob.perform_later(item.id)
    end
  end

  def create_blog_post_knowledge(post)
    KnowledgeItem.create!(
      content_type: "BlogPost",
      content_id: post.id,
      title: "Blog Post: #{post.title}",
      content: KnowledgeItem.send(:build_blog_content, post)
    ).tap do |item|
      VectorEmbeddingJob.perform_later(item.id)
    end
  end

  def rebuild_skills_knowledge
    # Delete all existing skills knowledge
    KnowledgeItem.where(content_type: "Skills").destroy_all

    # Rebuild skills knowledge by category
    Skill::CATEGORIES.each do |category|
      skills = Skill.by_category(category)
      next if skills.empty?

      KnowledgeItem.create!(
        content_type: "Skills",
        content_id: 0,
        title: "Skills: #{category}",
        content: KnowledgeItem.send(:build_skills_content, category, skills)
      ).tap do |item|
        VectorEmbeddingJob.perform_later(item.id)
      end
    end
  end
end

class PersonalInfo < ApplicationRecord
  has_rich_text :summary

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :title, presence: true

  # Knowledge base callbacks
  after_save :update_knowledge_base
  after_destroy :remove_from_knowledge_base

  def self.current
    first || new
  end

  def full_contact_info
    contact_details = []
    contact_details << email if email.present?
    contact_details << phone if phone.present?
    contact_details << location if location.present?
    contact_details.join(" • ")
  end

  def social_links
    links = []
    links << { name: "Website", url: website } if website.present?
    links << { name: "LinkedIn", url: linkedin } if linkedin.present?
    links << { name: "GitHub", url: github } if github.present?
    links << { name: "Twitter", url: twitter } if twitter.present?
    links
  end

  private

  def update_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("PersonalInfo", id, "update")
  end

  def remove_from_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("PersonalInfo", id, "delete")
  end
end

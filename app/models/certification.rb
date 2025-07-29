class Certification < ApplicationRecord
  validates :name, presence: true
  validates :issuer, presence: true
  validates :issue_date, presence: true
  validates :position, presence: true, uniqueness: true

  # Knowledge base callbacks
  after_save :update_knowledge_base
  after_destroy :remove_from_knowledge_base

  scope :ordered, -> { order(:position) }
  scope :active, -> { where("expiry_date IS NULL OR expiry_date > ?", Date.current) }
  scope :expired, -> { where("expiry_date IS NOT NULL AND expiry_date <= ?", Date.current) }

  def expired?
    expiry_date.present? && expiry_date <= Date.current
  end

  def expiry_status
    return "No expiration" unless expiry_date.present?

    if expired?
      "Expired on #{expiry_date.strftime('%b %Y')}"
    else
      days_until_expiry = (expiry_date - Date.current).to_i
      if days_until_expiry <= 30
        "Expires in #{days_until_expiry} days"
      else
        "Expires #{expiry_date.strftime('%b %Y')}"
      end
    end
  end

  def date_range
    issue_str = issue_date.strftime("%b %Y")
    if expiry_date.present?
      expiry_str = expiry_date.strftime("%b %Y")
      "#{issue_str} - #{expiry_str}"
    else
      "#{issue_str} - No expiration"
    end
  end

  private

  def update_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("Certification", id, "update")
  end

  def remove_from_knowledge_base
    KnowledgeBaseUpdateJob.perform_later("Certification", id, "delete")
  end
end

class SiteSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value_type, inclusion: { in: %w[string boolean integer] }

  def self.get(key)
    setting = find_by(key: key)
    return nil unless setting

    case setting.value_type
    when "boolean"
      setting.value == "true"
    when "integer"
      setting.value.to_i
    else
      setting.value
    end
  end

  def self.set(key, value, value_type = "string")
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.value_type = value_type
    setting.save!
  end
end

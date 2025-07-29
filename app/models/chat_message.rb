class ChatMessage < ApplicationRecord
  validates :question, presence: true
end

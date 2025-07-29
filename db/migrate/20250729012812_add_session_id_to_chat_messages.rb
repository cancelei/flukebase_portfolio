class AddSessionIdToChatMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_messages, :session_id, :string
  end
end

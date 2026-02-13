# frozen_string_literal: true

class MoveTaskDescriptionToActionText < ActiveRecord::Migration[7.0]
  def up
    # Copy plain text description to Action Text as HTML (single paragraph)
    rows = execute(<<-SQL.squish)
      SELECT id, description FROM tasks WHERE description IS NOT NULL AND description != ''
    SQL
    rows.each do |row|
      id = row["id"]
      plain = row["description"].to_s
      body = "<p>#{ERB::Util.html_escape(plain).gsub("\n", '<br>')}</p>"
      sql = "INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at) VALUES ('description', #{connection.quote(body)}, 'Task', #{connection.quote(id)}, NOW(), NOW())"
      execute sql
    end
    remove_column :tasks, :description
  end

  def down
    add_column :tasks, :description, :text
    Task.reset_column_information
    say_with_time "copy rich text body back to tasks.description (plain text)" do
      Task.find_each do |task|
        next unless task.respond_to?(:rich_text_description) && task.rich_text_description.present?

        plain = task.rich_text_description.body.to_plain_text
        task.update_column(:description, plain)
      end
    end
    execute "DELETE FROM action_text_rich_texts WHERE record_type = 'Task' AND name = 'description'"
  end
end

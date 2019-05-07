# frozen_string_literal: true

module Vitae
  # Create new configuration for a project
  class CreateNoteForProject
    def self.call(project_id:, note_data:)
      Project.first(id: project_id)
             .add_note(note_data)
    end
  end
end

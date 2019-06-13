# frozen_string_literal: true

module Vitae
  # Create new configuration for a sheet
  class CreateNoteForSheet
    def self.call(auth:, sheet_id:, note_data:)
      Sheet.first(id: sheet_id)
             .add_note(note_data)
    end
  end
end

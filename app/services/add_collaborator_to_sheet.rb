# frozen_string_literal: true

module Vitae
  # Add a collaborator to another owner's existing sheet
  class AddCollaboratorToSheet
    def self.call(email:, sheet_id:)
      collaborator = Account.first(email: email)
      sheet = Sheet.first(id: sheet_id)
      return false if sheet.owner.id == collaborator.id

      sheet.add_collaborator
      collaborator
    end
  end
end

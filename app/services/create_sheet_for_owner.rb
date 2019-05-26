# frozen_string_literal: true

module Vitae
  # Service object to create a new sheet for an owner
  class CreateSheetForOwner
    def self.call(owner_id:, sheet_data:)
      Account.find(id: owner_id)
             .add_owned_sheet(sheet_data)
    end
  end
end

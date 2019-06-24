# frozen_string_literal: true

module Vitae
  # Service object to create a new sheet for an owner
  class CreateSheet
    # Error class
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create sheets'
      end
    end

    def self.call(auth:, title:)
      raise ForbiddenError unless auth && auth[:scope].can_write?('sheets')
      email = auth[:account].email

      gsheet = GoogleSheets.new.new_sheet(
        email: email,
        title: title,
        template_id: Api.config.SHEET_TEMPLATE_ID)

      Account.find(id: auth[:account].id)
             .add_owned_sheet(title: gsheet[:title], file_id: gsheet[:file_id])
    end
  end
end

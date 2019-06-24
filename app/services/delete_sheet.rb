# frozen_string_literal: true

module Vitae
  # Service object to create a new sheet for an owner
  class DeleteSheet
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete sheets'
      end
    end

    class NotFoundError < StandardError
      def message
        'Sheet not found'
      end
    end

    def self.call(auth:, file_id:)
      raise ForbiddenError unless auth

      sheet = Sheet.first(file_id: file_id)
      raise NotFoundError unless sheet

      policy = SheetPolicy.new(
        account: auth[:account],
        sheet: sheet,
        auth_scope: auth[:scope]
       )

      raise ForbiddenError unless policy.can_delete?

      sheet.destroy
      GoogleSheets.new.delete_sheet(file_id: file_id)
    end
  end
end

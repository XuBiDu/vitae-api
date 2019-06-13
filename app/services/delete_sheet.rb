# frozen_string_literal: true

module Vitae
  # Service object to create a new sheet for an owner
  class DeleteSheet
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete sheets'
      end
    end

    def self.call(auth:, file_id:)
      # raise ForbiddenError unless auth[:scope].can_write?('sheets')

      Sheet.where(file_id: file_id).destroy
      GoogleSheets.new.delete_sheet(file_id: file_id)
    end
  end
end

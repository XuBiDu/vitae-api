# frozen_string_literal: true

module Vitae
  # Get one sheet
  class GetSheet
    # Error
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access this sheet'
      end
    end

    # Error for cannot find a sheet
    class NotFoundError < StandardError
      def message
        'We could not find this sheet'
      end
    end

    def self.call(auth:, file_id:)
      raise ForbiddenError unless auth

      sheet = Sheet.first(file_id: file_id)
      raise NotFoundError unless sheet

      policy = SheetPolicy.new(account: auth[:account],
                               sheet: sheet,
                               auth_scope: auth[:scope]
                              )

      raise ForbiddenError unless policy.can_view?

      sheet.everything.merge(policies: policy.summary)
    end
  end
end
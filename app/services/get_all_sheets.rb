# frozen_string_literal: true

module Vitae
  # Add a collaborator to another owner's existing sheet
  class GetAllSheets
    def self.call(account:)
      sheets = SheetPolicy::Scope.new(account).viewable

      sheets.map do |sheet|
        sheet.everything.merge(policies: SheetPolicy.new(account: account, sheet: sheet).summary)
      end
    end
  end
end

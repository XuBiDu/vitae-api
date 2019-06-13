# frozen_string_literal: true

module Vitae
  # Add a collaborator to another owner's existing sheet
  class GetAllSheets
    def self.call(auth:)
      puts auth[:account].inspect
      sheets = SheetPolicy::Scope.new(auth[:account]).viewable
      sheets.map do |sheet|
        sheet.everything.merge(policies: SheetPolicy.new(account: auth[:account], sheet: sheet, auth_scope: auth[:scope]).summary)
      end
    end
  end
end

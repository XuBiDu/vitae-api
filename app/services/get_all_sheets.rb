# frozen_string_literal: true

module Vitae
  # Add a collaborator to another owner's existing sheet
  class GetAllSheets
    def self.call(auth:)
      sheets = SheetPolicy::Scope.new(auth[:account]).viewable
      sheets.map do |sheet|
        policy = SheetPolicy.new(account: auth[:account],
                                 sheet: sheet,
                                 auth_scope: auth[:scope]
                                )
        sheet.everything.merge(policies: policy.summary)
      end
    end
  end
end

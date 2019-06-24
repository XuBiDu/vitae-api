# frozen_string_literal: true

module Vitae
  # Policy to determine if account can view a sheet
  class SheetPolicy
    # Scope of sheet policies
    class Scope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_sheets(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |sheet|
            includes_collaborator?(sheet, @current_account)
          end
        end
      end

      private

      def all_sheets(account)
        account.owned_sheets + account.collaborations
      end

      def includes_collaborator?(sheet, account)
        sheet.collaborators.include? account
      end
    end
  end
end

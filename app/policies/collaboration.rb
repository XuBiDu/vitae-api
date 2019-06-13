# frozen_string_literal: true

module Vitae
  # Policy to determine if an account can view a particular sheet
  class CollaborationRequestPolicy
    def initialize(sheet:, account:, collaborator:, scope:)
      @sheet = sheet
      @requestor_account = account
      @target_account = collaborator
      @auth_scope = scope
      @requestor = SheetPolicy.new(account: @requestor_account, sheet: sheet, auth_scope: @auth_scope)
      @target = SheetPolicy.new(account: @target_account, sheet: sheet, auth_scope: @auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_collaborators? && @target.can_collaborate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_collaborators? && target_is_collaborator?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('sheets') : false
    end

    def target_is_collaborator?
      @sheet.collaborators.include?(@target_account)
    end
  end
end

# frozen_string_literal: true

module Vitae
  # Add a collaborator to another owner's existing sheet
  class AddCollab
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to share with this user'
      end
    end
    class NotFoundError < StandardError
      def message
        'Collaborator not found'
      end
    end

    def self.call(auth:, collab_email:, file_id:)
      raise ForbiddenError unless auth

      sheet = Sheet.first(file_id: file_id)
      collaborator = Account.first(email: collab_email)
      raise NotFoundError unless collaborator

      policy = CollaborationRequestPolicy.new(
        sheet: sheet,
        account: auth[:account],
        scope: auth[:scope],
        collaborator: collaborator
      )
      raise ForbiddenError unless policy.can_invite?

      sheet.add_collaborator(collaborator)
      GoogleSheets.new.share(file_id: file_id, email: collab_email)
      collaborator
    end
  end
  # Add a collaborator to another owner's existing sheet
  class RemoveCollab
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove this user'
      end
    end
    class NotFoundError < StandardError
      def message
        'Collaborator not found'
      end
    end

    def self.call(auth:, collab_email:, file_id:)
      raise ForbiddenError unless auth

      sheet = Sheet.first(file_id: file_id)
      collaborator = Account.first(email: collab_email)
      raise NotFoundError unless collaborator

      policy = CollaborationRequestPolicy.new(
        sheet: sheet,
        account: auth[:account],
        scope: auth[:scope],
        collaborator: collaborator
      )
      raise ForbiddenError unless policy.can_remove?

      sheet.remove_collaborator(collaborator)
      GoogleSheets.new.unshare(
        file_id: file_id,
        email: collab_email)

      collaborator
    end
  end
end

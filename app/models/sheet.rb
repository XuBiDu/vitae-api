# frozen_string_literal: true

require 'json'
require 'sequel'

module Vitae
  # Models a sheet
  class Sheet < Sequel::Model
    many_to_one :owner, class: :'Vitae::Account'

    many_to_many :collaborators,
                 class: :'Vitae::Account',
                 join_table: :accounts_sheets,
                 left_key: :sheet_id, right_key: :collaborator_id

    plugin :association_dependencies,
           collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :file_id, :title

    def to_h
      {
        type: 'sheet',
        attributes: {
          id: id,
          title: title,
          file_id: file_id,
          file_token: SecureMessage.encrypt(file_id)
        }
      }
    end

    def everything
      to_h.merge(
        relationships: {
          owner: owner,
          collaborators: collaborators,
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
    # rubocop:enable MethodLength
  end
end
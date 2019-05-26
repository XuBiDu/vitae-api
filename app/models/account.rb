# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Vitae
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_sheets, class: :'Vitae::Sheet', key: :owner_id

    many_to_many :collaborations,
                 class: :'Vitae::Sheet',
                 join_table: :accounts_sheets,
                 left_key: :collaborator_id, right_key: :sheet_id

    plugin :association_dependencies, owned_sheets: :destroy, collaborations: :nullify
    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def sheets
      puts 'in sheets'
      puts owned_sheets.inspect
      puts collaborations.inspect

      owned_sheets + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Vitae::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username: username,
            email: email
          }
        }, options
      )
    end
  end
end

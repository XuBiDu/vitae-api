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
    set_allowed_columns :sub, :name, :given_name, :family_name,
                        :picture, :email, :locale, :username, :password

    plugin :timestamps, update_on_create: true

    def sheets
      owned_sheets + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Vitae::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def self.create_google_account(google_account)
      puts 'creating account'
      puts google_account.email
      create(sub: google_account.sub,
             email: google_account.email,
             username: google_account.email,
             name: google_account.name,
             given_name: google_account.given_name,
             family_name: google_account.family_name,
             locale: google_account.locale,
             picture: google_account.picture
            )
    end


    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            sub: sub,
            email: email,
            username: username,
            name: name,
            given_name: given_name,
            family_name: family_name,
            locale: locale,
            picture: picture
          }
        }, options
      )
    end
  end
end

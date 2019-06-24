# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id

      String :sub
      String :name
      String :username
      String :given_name
      String :family_name
      String :picture
      String :email, null: false, unique: true
      String :locale
      String :password_digest
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

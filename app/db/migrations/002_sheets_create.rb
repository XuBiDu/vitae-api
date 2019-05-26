# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:sheets) do
      primary_key :id
      String :name, unique: true, null: false
      String :file_id, unique: true, null: false
      foreign_key :owner_id, :accounts

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

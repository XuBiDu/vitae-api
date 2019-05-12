# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:notes) do
      uuid :id, primary_key: true
      foreign_key :project_id, table: :projects

      String :text_secure

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

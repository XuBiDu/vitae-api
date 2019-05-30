# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    create_accounts
    create_owned_sheets
    create_notes
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_sheets.yml")
SHEET_INFO = YAML.load_file("#{DIR}/sheets_seed.yml")
NOTE_INFO = YAML.load_file("#{DIR}/notes_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/sheets_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Vitae::Account.create(account_info)
  end
end

def create_owned_sheets
  OWNER_INFO.each do |owner|
    account = Vitae::Account.first(username: owner['username'])
    owner['sheet_name'].each do |sheet_name|
      sheet_data = SHEET_INFO.find { |sheet| sheet['name'] == sheet_name }
      Vitae::CreateSheetForOwner.call(
        owner_id: account.id, sheet_data: sheet_data
      )
    end
  end
end

def create_notes
  note_info_each = NOTE_INFO.each
  sheets_cycle = Vitae::Sheet.all.cycle
  loop do
    note_info = note_info_each.next
    sheet = sheets_cycle.next
    Vitae::CreateNoteForSheet.call(
      sheet_id: sheet.id, note_data: note_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    sheet = Vitae::Sheet.first(name: contrib['sheet_name'])
    contrib['collaborator_email'].each do |email|
      collaborator = Vitae::Account.first(email: email)
      sheet.add_collaborator(collaborator)
    end
  end
end

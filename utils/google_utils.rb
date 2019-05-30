# frozen_string_literal: true
require "google_drive"
require 'yaml'

class GoogleUtils
  def initialize
    conf = YAML.load_file('../config/secrets.yml')['development']

    ENV['GOOGLE_ACCOUNT_TYPE'] = conf['GOOGLE_ACCOUNT_TYPE']
    ENV['GOOGLE_CLIENT_ID'] = conf['GOOGLE_CLIENT_ID']
    ENV['GOOGLE_CLIENT_EMAIL'] = conf['GOOGLE_CLIENT_EMAIL']
    ENV['GOOGLE_PRIVATE_KEY'] = conf['GOOGLE_PRIVATE_KEY']
    @template = conf['SHEET_TEMPLATE_ID']
    @session = GoogleDrive::Session.from_service_account_key(nil)
  end

  def files
    @session.files
  end

  def sheet_data(file_id:)
    spreadsheet = @session.file_by_id(file_id)
    worksheets = spreadsheet.worksheets
    worksheets.map(&:rows)
  end

  def session
    @session
  end

  def template
    @template
  end
end

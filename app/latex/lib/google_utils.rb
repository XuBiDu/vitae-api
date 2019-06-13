# frozen_string_literal: true
require "google_drive"
require 'yaml'

class GoogleUtils
  def initialize(config)
    # conf = YAML.load_file('../config/secrets.yml')['development']
    @template = config['SHEET_TEMPLATE_ID']
    @session = GoogleDrive::Session.from_service_account_key(nil)
  end

  def files
    @session.files
  end

  def sheet_data(file_id:)
    spreadsheet = @session.file_by_id(file_id)
    worksheets = spreadsheet.worksheets
    worksheets.map{ |ws| { 'title' => ws.title, 'rows' => ws.rows } }
  end

  def session
    @session
  end

  def template
    @template
  end
end

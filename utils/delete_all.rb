# frozen_string_literal: true
require "google_drive"
require 'yaml'
require_relative 'google_utils'

files = GoogleUtils.new.files

files.each do |f|
  puts f
  # f.delete(permanent: true) if f.mime_type == 'application/vnd.google-apps.spreadsheet'
end

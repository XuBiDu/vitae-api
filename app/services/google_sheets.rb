# frozen_string_literal: true
require "google_drive"

module Vitae
  # Service object to create a new sheet for an owner
  class GoogleSheets
    def initialize
      puts 'GS.initialize'
      @session = GoogleDrive::Session.from_service_account_key(nil)
    end

    def new_sheet(email:, title:, template_id:)
      puts 'GS.new_sheet'
      newsheet = @session.file_by_id(template_id).duplicate(title, file_properties: {writersCanShare: false})
      user_folder(email: email).add(newsheet)
      newsheet.acl.push({type: "user", email_address: email, role: "writer"},
                        {send_notification_email: false})
      {file_id: newsheet.id, title: newsheet.title}
    end

    def delete_sheet(file_id:)
      puts 'GS.delete_sheet'
      @session.file_by_id(file_id).delete(false) # move to trash
    end

    def share(file_id:, email:)
      puts 'GS.share'
      sheet = @session.file_by_id(file_id)
      sheet.acl.push(
        {type: 'user', email_address: email, role: 'writer'}, {send_notification_email: false})
    end

    def unshare(file_id:, email:)
      puts 'GS.unshare'
      sheet = @session.file_by_id(file_id)
      sheet.acl.each do |entry|
        sheet.acl.delete(entry) if entry.email_address == email
      end
    end

    def sheet_data(file_id:)
      spreadsheet = @session.file_by_id(file_id)
      worksheets = spreadsheet.worksheets
    end

    # private

    def user_folder(email:)
      puts 'GS.user_folder'
      drive = @session.file_by_id('root')
      top = drive.subfolder_by_name('Root') || drive.create_subfolder('Root')
      top.subfolder_by_name(email) || top.create_subfolder(email)
    end
  end
end

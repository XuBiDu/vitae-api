# frozen_string_literal: true
require "google_drive"

module Vitae
  # Service object to create a new sheet for an owner
  class GoogleSheets
    def initialize
      @session = GoogleDrive::Session.from_service_account_key(nil)
    end

    def new_sheet(email:, title:, template_id:)
      newsheet = @session.file_by_id(template_id).duplicate(title)
      user_folder(email: email).add(newsheet)
      newsheet.acl.push({type: "user", email_address: email, role: "writer"},
                        {send_notification_email: false})
      {file_id: newsheet.id, title: newsheet.title}
    end

    def delete_sheet(file_id:)
      @session.file_by_id(file_id).delete(false) # move to trash
    end

    def share(file_id:, email:)
      puts 'in share'
      sheet = @session.file_by_id(file_id)
      sheet.acl.push(
        {type: 'user', email_address: email, role: 'writer'}, {send_notification_email: false})
    end

    def unshare(file_id:, email:)
      puts 'in unshare'
      sheet = @session.file_by_id(file_id)
      sheet.acl.each do |entry|
        sheet.acl.delete(entry) if entry.email_address == email
      end
    end

    def sheet_data(file_id:)
      spreadsheet = @session.file_by_id(file_id)
      worksheets = spreadsheet.worksheets
      # worksheets.each do |ws|
      #   puts ws.rows
      # end
    end

    # private

    def user_folder(email:)
      drive = @session.file_by_id('root')
      top = drive.subfolder_by_name('Root') || drive.create_subfolder('Root')
      # aclf = top.acl.push(
      #    {type: "user", email_address: "vitae2app@gmail.com", role: "writer"},
      #    {send_notification_email: false})
      # exit
      top.subfolder_by_name(email) || top.create_subfolder(email)
    end
  end
end

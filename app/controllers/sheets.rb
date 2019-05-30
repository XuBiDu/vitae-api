# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('sheets') do |routing|
      @sheet_route = "#{@api_root}/sheets"
      # GET api/v1/sheets
      routing.get do
        puts 'there'
        sheets = GetAllSheets.call(account: @auth_account)
        JSON.pretty_generate(data: sheets)
      # rescue StandardError
      #   routing.halt 403, { message: 'Could not find any sheets' }.to_json
      end

      # POST api/v1/sheets
      routing.post do
        account = Account.first(username: @auth_account['username'])
        puts account.inspect
        puts @auth_account.inspect
        title = "#{@auth_account['username']}'s CV"
        gsheet = GoogleSheets.new.new_sheet(email: @auth_account['email'],
                                         title: title,
                                         template_id: Api.config.SHEET_TEMPLATE_ID)

        sheet_data = {file_id: gsheet[:file_id], name: gsheet[:title]}
        new_sheet = CreateSheetForOwner.call(owner_id: account.id, sheet_data: sheet_data)
        raise('Could not create sheet') unless new_sheet

        response.status = 201
        response['Location'] = "#{@sheet_route}/#{new_sheet.id}"
        { message: 'Sheet saved', data: new_sheet }.to_json
      rescue StandardError => error
        routing.halt 400, { message: error.message }.to_json
      end
    end
  end
end

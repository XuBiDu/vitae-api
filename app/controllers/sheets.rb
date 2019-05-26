# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda

    route('sheets') do |routing|
      @sheet_route = "#{@api_root}/sheets"

      routing.on String do |sheet_id|
        routing.on 'notes' do
          @note_route = "#{@api_root}/sheets/#{sheet_id}/notes"
          # GET api/v1/sheets/[GID]/notes/[HID]
          routing.get String do |note_id|
            note = Note.where(sheet_id: sheet_id, id: note_id).first
            note ? note.to_json : raise('Note not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/sheets/[GID]/notes
          routing.get do
            output = { data: Sheet.first(id: sheet_id).notes }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find notes'
          end

          # POST api/v1/sheets/[GID]/notes
          routing.post do
            new_data = JSON.parse(routing.body.read)
            sheet = Sheet.first(id: sheet_id)

            new_note = sheet.add_note(new_data)
            raise 'Could not save note' unless new_note

            if new_note
              response.status = 201
              response['Location'] = "#{@note_route}/#{new_note.id}"
              { message: 'Note saved', data: new_note }.to_json
            else
              routing.halt 400, 'Could not save note'
            end

          rescue StandardError
            routing.halt 400, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/sheets/[GID]
        routing.get do
          sheet = Sheet.first(id: sheet_id)
          sheet ? sheet.to_json : raise('Sheet not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # GET api/v1/sheets
      routing.get do
        account = Account.first(username: @auth_account['username'])
        sheets = account.sheets
        JSON.pretty_generate(data: sheets)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any sheets' }.to_json
      end

      # POST api/v1/sheets
      routing.post do
        new_data = JSON.parse(routing.body.read)
        gsheet = GoogleSheet.new
        new_sheet = Sheet.new({file_id: gsheet.file_id, name: new_data.name})
        raise('Could not save sheet') unless new_sheet.save

        response.status = 201
        response['Location'] = "#{@sheet_route}/#{new_sheet.id}"
        { message: 'Sheet saved', data: new_sheet }.to_json
      rescue StandardError => error
        routing.halt 400, { message: error.message }.to_json
      end
    end
  end
end

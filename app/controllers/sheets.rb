# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('sheets') do |r|
      # GET api/v1/sheets
      r.get do
        sheets = GetAllSheets.call(auth: @auth)
        JSON.pretty_generate(data: sheets)
      rescue StandardError
        r.halt 403, { message: 'Could not find any sheets' }.to_json
      end

      # POST api/v1/sheets
      r.post do
        @sheet_route = "#{@api_root}/sheet"
        req_data = JSON.parse(r.body.read)
        new_sheet = CreateSheet.call(
          auth: @auth,
          title: req_data['title']
        )

        raise('Wrong data') unless req_data.keys.sort == ['title'].sort
        raise('Could not create sheet') unless new_sheet

        response.status = 201
        response['Location'] = "#{@sheet_route}/#{new_sheet.file_id}"
        { message: 'Sheet saved', data: new_sheet }.to_json
      # rescue CreateSheet::ForbiddenError => e
      #   r.halt 403, { message: e.message }.to_json
      # rescue StandardError => e
      #   r.halt 400, { message: e.message }.to_json
      end
    end
  end
end

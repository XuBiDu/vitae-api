# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('sheet') do |routing|
      @sheet_route = "#{@api_root}/sheet"
      routing.on String do |file_id|
        routing.on 'view' do
          @view_route = "#{@api_root}/sheet/#{file_id}/view"
          # GET api/v1/sheet/[FID]/view
          routing.get do
            GoogleSheets.new.sheet_data(file_id: file_id)
            JSON.pretty_generate({hello: "hi there"}) # !!
          rescue StandardError
            routing.halt 403, { message: 'Could not view sheet' }.to_json
          end
        end

        routing.on 'collab' do
          # PUT api/v1/sheet/[FID]/collab

          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              account: @auth_account,
              sheet: @req_sheet,
              collab_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/sheet/[FID]/collab
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              req_username: @auth_account.username,
              collab_email: req_data['email'],
              sheet_id: file_id
            )

            { message: "#{collaborator.username} removed from sheet",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

        end

      end
    end
  end
end

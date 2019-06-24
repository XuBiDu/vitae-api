# frozen_string_literal: true

require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('sheet') do |r| # rubocop:disable Metrics/BlockLength
      @sheet_route = "#{@api_root}/sheet"
      r.on String do |file_id|
        r.on 'collabs' do #
          # PUT api/v1/sheet/[file_id]/collabs
          r.put do
            req_data = JSON.parse(r.body.read)
            collaborator = AddCollab.call(
              auth: @auth,
              collab_email: req_data['email'],
              file_id: file_id
            )

            { message: "#{collaborator.username} added to CV",
              data: collaborator }.to_json
          rescue AddCollab::ForbiddenError => e
            r.halt 403, { message: e.message }.to_json
          rescue AddCollab::NotFoundError => e
            r.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            r.halt 500, { message: e.message }.to_json
          end

          # DELETE api/v1/sheet/[file_id]/collabs
          r.delete do
            req_data = JSON.parse(r.body.read)
            collaborator = RemoveCollab.call(
              auth: @auth,
              collab_email: req_data['email'],
              file_id: file_id
            )

            { message: "#{collaborator.username} removed from CV",
              data: collaborator }.to_json
          rescue RemoveCollab::ForbiddenError => e
            r.halt 403, { message: e.message }.to_json
          rescue RemoveCollab::NotFoundError
            r.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            r.halt 500, { message: e.message }.to_json
          end
        end

        # DELETE api/v1/sheet/[file_id]
        r.delete do
          DeleteSheet.call(auth: @auth, file_id: file_id)
          response.status = 200
          { message: 'Sheet deleted' }.to_json
        rescue DeleteSheet::ForbiddenError => e
          r.halt 403, { message: e.message }.to_json
        rescue DeleteSheet::NotFoundError => e
          r.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          r.halt 500, { message: e.message }.to_json
        end

        # GET api/v1/sheet/[file_id]
        r.get do
          sheet = GetSheet.call(auth: @auth, file_id: file_id)
          response.status = 200
          JSON.pretty_generate(data: sheet)
        rescue GetSheet::ForbiddenError => e
          r.halt 403, { message: e.message }.to_json
        rescue GetSheet::NotFoundError => e
          r.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          r.halt 500, { message: e.message }.to_json
        end
      end
    end
  end
end

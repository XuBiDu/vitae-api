# frozen_string_literal: true

require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('sheet') do |r|
      @sheet_route = "#{@api_root}/sheet"
      r.on String do |file_id|
        # DELETE api/v1/sheet/[proj_id]/collabs
        r.on 'collabs' do # rubocop:disable Metrics/BlockLength
          r.put do
            puts 'Adding collaborator'
            req_data = JSON.parse(r.body.read)
            collaborator = AddCollab.call(
              auth: @auth,
              collab_email: req_data['email'],
              file_id: file_id
            )

            { data: collaborator }.to_json
          rescue AddCollab::ForbiddenError => e
            r.halt 403, { message: e.message }.to_json
          rescue StandardError
            r.halt 500, { message: 'API server error' }.to_json
          end

        # DELETE api/v1/sheet/[proj_id]/collabs
          r.delete do
            puts 'Removing collaborator'
            req_data = JSON.parse(r.body.read)
            collaborator = RemoveCollab.call(
              auth: @auth,
              collab_email: req_data['email'],
              file_id: file_id
            )

            { message: "#{collaborator.username} removed from projet",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            r.halt 403, { message: e.message }.to_json
          rescue StandardError
            r.halt 500, { message: 'API server error' }.to_json
          end
        end

        r.delete do
          puts 'delete'
          DeleteSheet.call(auth: @auth, file_id: file_id)
          response.status = 200
          { message: 'Sheet deleted' }.to_json
        rescue StandardError
          r.halt 403, { message: 'Could not delete CV' }.to_json
        end
        r.on 'view' do
          @view_route = "#{@api_root}/sheet/#{file_id}/view"
          # GET api/v1/sheet/[FID]/view
          r.get do
            GoogleSheets.new.sheet_data(file_id: file_id)
            JSON.pretty_generate({hello: "hi there"}) # !!
          rescue StandardError
            r.halt 403, { message: 'Could not view sheet' }.to_json
          end
        end

        r.on 'link' do
          r.get do
            file_id_token = SecureMessage.encrypt(file_id)
            JSON.pretty_generate({file_id_token: file_id_token})
          end
        end
      end
    end
  end
end

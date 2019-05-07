# frozen_string_literal: true

require 'roda'
require 'json'

# rubocop:disable Metrics/BlockLength
module Vitae
  # Web controller for Vitae API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Vitae up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Project saved', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            puts e.inspect
            routing.halt 500, { message: error.message }.to_json
          end
        end

        routing.on 'projects' do
          @project_route = "#{@api_root}/projects"

          routing.on String do |project_id|
            routing.on 'notes' do
              @note_route = "#{@api_root}/projects/#{project_id}/notes"
              # GET api/v1/projects/[GID]/notes/[HID]
              routing.get String do |note_id|
                note = Note.where(project_id: project_id, id: note_id).first
                note ? note.to_json : raise('Note not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/projects/[GID]/notes
              routing.get do
                output = { data: Project.first(id: project_id).notes }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find notes'
              end

              # POST api/v1/projects/[GID]/notes
              routing.post do
                new_data = JSON.parse(routing.body.read)
                project = Project.first(id: project_id)

                new_note = project.add_note(new_data)
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

            # GET api/v1/projects/[GID]
            routing.get do
              project = Project.first(id: project_id)
              project ? project.to_json : raise('Project not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # GET api/v1/projects
          routing.get do
            output = { data: Project.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find projects' }.to_json
          end

          # POST api/v1/projects
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_project = Project.new(new_data)
            raise('Could not save project') unless new_project.save

            response.status = 201
            response['Location'] = "#{@project_route}/#{new_project.id}"
            { message: 'Project saved', data: new_project }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
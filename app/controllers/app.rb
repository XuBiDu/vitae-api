# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/hand'

module CheatChat
  # Web controller for Cheat API
  class Api < Roda
    plugin :halt
    plugin :environments

    # Initialize Hand
    configure do
      Hand.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CheatChatAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'hand' do
            # GET api/v1/hand/[id]
            routing.get String do |id|
              Hand.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Hand not found' }.to_json
            end

            # GET api/v1/hand
            routing.get do
              output = { hand_ids: Hand.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/hand
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_hand = Hand.new(new_data)

              if new_hand.save
                response.status = 201
                { message: 'Hand saved', id: new_hand.id }.to_json
              else
                routing.halt 400, { message: 'Could not save hand' }.to_json
              end
            end
          end
        end
      end
    end
  end
end

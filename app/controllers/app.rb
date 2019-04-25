# frozen_string_literal: true

require 'roda'
require 'json'

# rubocop:disable Metrics/BlockLength
module CheatChat
  # Web controller for CheatChat API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CheatChat up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'games' do
          @game_route = "#{@api_root}/games"

          routing.on String do |game_id|
            routing.on 'hands' do
              @hand_route = "#{@api_root}/games/#{game_id}/hands"
              # GET api/v1/games/[GID]/hands/[HID]
              routing.get String do |hand_id|
                hand = Hand.where(game_id: game_id, id: hand_id).first
                hand ? hand.to_json : raise('Hand not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/games/[GID]/hands
              routing.get do
                output = { data: Game.first(id: game_id).hands }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find hands'
              end

              # POST api/v1/games/[GID]/hands
              routing.post do
                new_data = JSON.parse(routing.body.read)
                game = Game.first(id: game_id)

                new_hand = game.add_hand(new_data)
                raise 'Could not save hand' unless new_hand

                if new_hand
                  response.status = 201
                  response['Location'] = "#{@hand_route}/#{new_hand.id}"
                  { message: 'Hand saved', data: new_hand }.to_json
                else
                  routing.halt 400, 'Could not save hand'
                end

              rescue StandardError
                routing.halt 400, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/games/[GID]
            routing.get do
              game = Game.first(id: game_id)
              game ? game.to_json : raise('Game not found')
            rescue StandardError => error
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # GET api/v1/games
          routing.get do
            output = { data: Game.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find games' }.to_json
          end

          # POST api/v1/games
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_game = Game.new(new_data)
            raise('Could not save game') unless new_game.save

            response.status = 201
            response['Location'] = "#{@game_route}/#{new_game.id}"
            { message: 'Game saved', data: new_game }.to_json
          rescue StandardError => error
            routing.halt 400, { message: error.message }.to_json
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
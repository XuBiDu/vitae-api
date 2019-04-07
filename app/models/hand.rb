# frozen_string_literal: true

require 'base64'
require 'json'
require 'rbnacl'

module CheatChat
  # A dealt hand
  class Hand
    STASH_DIR = 'app/db/stash/'
    STASH_SUFFIX = '.json'

    attr_reader :id, :cards, :player_id

    def initialize(hand)
      @id = hand['id'] || new_id
      @cards = hand['cards']
      @player_id = hand['player_id']
    end

    def to_json
      JSON.pretty_generate(
        {
          cards: cards,
          player_id: player_id
        }
      )
    end

    def self.setup
      Dir.mkdir(STASH_DIR) unless Dir.exist? STASH_DIR
    end

    # Save hand in stash
    def save
      File.write(STASH_DIR + id + STASH_SUFFIX, to_json)
    end

    # Find hand by id
    def self.find(find_id)
      hand_file = File.read(STASH_DIR + find_id + STASH_SUFFIX)
      Hand.new JSON.parse(hand_file)
    end

    def self.all
      Dir.glob(STASH_DIR + '*' + STASH_SUFFIX).map do |path|
        File.basename(path).sub(Regexp.new(STASH_SUFFIX + '$'), '')
      end
    end

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..15]
    end
  end
end

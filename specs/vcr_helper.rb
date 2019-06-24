# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
class VcrHelper
  CASSETTES_FOLDER = 'specs/fixtures/cassettes'
  CASSETTE_FILE = 'secret'
  LOG_FILE = 'log.txt'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_localhost = true
      c.debug_logger = File.open("#{CASSETTES_FOLDER}/#{LOG_FILE}", 'w')
    end
  end

  def self.configure_vcr_for_google(recording: :new_episodes)
    VCR.configure do |c|
      # c.filter_sensitive_data('<GOOGLE_ACCOUNT_TYPE>') { Vitae::Api.config.GOOGLE_ACCOUNT_TYPE }
      # c.filter_sensitive_data('<GOOGLE_CLIENT_ID>') { Vitae::Api.config.GOOGLE_CLIENT_ID }
      # c.filter_sensitive_data('<GOOGLE_CLIENT_EMAIL>') { Vitae::Api.config.GOOGLE_CLIENT_EMAIL }
      # c.filter_sensitive_data('<GOOGLE_PRIVATE_KEY>') { Vitae::Api.config.GOOGLE_PRIVATE_KEY }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: recording,
      match_requests_on: %i[uri method body],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end

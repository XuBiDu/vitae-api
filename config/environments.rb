# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'logger'
require_app('lib')

module Vitae
  # Configuration for the API
  class Api < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :development, :test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME

      ENV['GOOGLE_ACCOUNT_TYPE'] = config.GOOGLE_ACCOUNT_TYPE
      ENV['GOOGLE_CLIENT_ID'] = config.GOOGLE_CLIENT_ID
      ENV['GOOGLE_CLIENT_EMAIL'] = config.GOOGLE_CLIENT_EMAIL
      ENV['GOOGLE_PRIVATE_KEY'] = config.GOOGLE_PRIVATE_KEY
    end

    # configure :development, :test do
    #   ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
    # end

    configure :production do
      # Production platform should specify DATABASE_URL environment variable
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])
      DB.sql_log_level = :debug

      DB.loggers << Logger.new($stdout)

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
      SecureMessage.setup(config) # Load crypto keys
      AuthToken.setup(config.MSG_KEY) # Load crypto keys
      SecureDB.setup(config.DB_KEY) # Load crypto keys
    end
  end
end

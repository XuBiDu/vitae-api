# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'logger'
require './app/lib/secure_db'

module Vitae
  # Configuration for the API
  class Api < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :development, :test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
    end

    configure :production do
      # Production platform should specify DATABASE_URL environment variable
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])
      # DB.loggers << Logger.new($stdout)

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end

      SecureDB.setup(config) # Load crypto keys
    end
  end
end

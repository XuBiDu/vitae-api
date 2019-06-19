# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task :default => :specs

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby specs/api_spec.rb'
end

desc 'Test all the specs'
Rake::TestTask.new(:specs) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task :style do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task :release? => [:spec, :style, :audit] do
  puts "\nReady for release!"
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./specs/test_load_all'
end

namespace :latex do
  desc 'Plasmati CV'
  task :plasmati do
    require_app(%w[latex])
    File.open('cv.tex', 'w') do |f|
      # use "\n" for two lines of text
      f.puts GSheet2Latex.new(config: Vitae::Api.config).render(template: Plasmati)
    end
  end
end

namespace :db do
  require_relative 'config/environments.rb' # load config info
  require 'sequel'

  Sequel.extension :migration
  app = Vitae::Api

  desc 'Run migrations'
  task :migrate => :print_env do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'app/db/migrations')
  end

  desc 'Delete database'
  task :delete => [:load_models] do
      Vitae::Account.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end

  desc 'Delete and migrate again'
  task reset: [:drop, :migrate]

  # desc 'Create sample cryptographic key for database'
  # task :newkey do
  #   require_app('lib')
  #   puts "DB_KEY: #{SecureDB.generate_key}"
  # end

  namespace :newkey do
    desc 'Create sample cryptographic key for database'
    task :db do
      require_app('lib')
      puts "DB_KEY: #{SecureDB.generate_key}"
    end

    desc 'Create sample cryptographic key for tokens and messaging'
    task :msg do
      require_app('lib')
      puts "MSG_KEY: #{AuthToken.generate_key}"
    end
    desc 'Create sample sign/verify keypair for signed communication'
    task :signing => :load_libs do
    keypair = SignedRequest.generate_keypair

    puts "SIGNING_KEY: #{keypair[:signing_key]}"
    puts " VERIFY_KEY: #{keypair[:verify_key]}"
    end
  end

  end

  task :load_models do
    require_app(%w[lib models services])
  end

  task :reset_seeds => [:load_models] do
    puts app.DB[:schema_seeds]
    app.DB[:schema_seeds].delete if app.DB.tables.include?(:schema_seeds)
    Vitae::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed => [:load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(app.DB, 'app/db/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]
end

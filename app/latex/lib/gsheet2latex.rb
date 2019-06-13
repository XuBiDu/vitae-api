# frozen_string_literal: true
# require_relative 'taraborelli'
# require_relative 'google_utils'
# require_relative 'wsheet'
require 'yaml'

# class for converting GSheet to Latex
class GSheet2Latex
  attr_reader :data

  def initialize(config:, file_id: nil)
    @config = config
    @gu = GoogleUtils.new(config)
    @file_id = file_id || @gu.template
    puts @file_id
    @sheets = load
  end

  def fname
    "#{@config.LATEX_CACHE}/#{@file_id}.yml"
  end

  def load()
  puts fname
    puts "Loading #{@file_id}"
    begin
      data = YAML.safe_load(File.read(fname))
    rescue StandardError => e
      puts 'Cannot load'
      puts "Fetching #{@file_id}"
      data = @gu.sheet_data(file_id: @file_id)
    end
    begin
      puts "Saving #{@file_id}"
      File.open(fname, 'w') { |file| file.write(data.to_yaml) }
    rescue StandardError => e
      puts 'Cannot save'
    end
    puts "Done #{@file_id}"
    data.each_with_index.map { |ws, index| Worksheet.new(wsheet: ws, index: index) }
  end

  def render(engine:)
    sio = StringIO.new
    sio.write engine.prolog
    @sheets.each do |sheet|
      puts "#{sheet.index} #{sheet.title}"
      sio.write engine.render sheet.parse
    end
    sio.write engine.epilog
    sio.string
  end
end

# puts GSheet2Latex.new.data.inspect
# g2l = GSheet2Latex.new
# g2l.load
# ws = GSheet2Latex::Worksheet.new(wsheet: g2l.data[1])
# puts ws.inspect
# puts ws.option?("big")
# File.open(filename, 'w') do |file|
# g2l = GSheet2Latex.new(App.config)
# g2l.render(engine: Taraborelli, filename: 'cv.tex')
# # a = Taraborelli.new
# # puts a.prolog
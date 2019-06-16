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

  def render(template: Plasmati)
    sio = StringIO.new
    sio.write template.prolog + "\n"
    sio.write render_sheets(template: template) + "\n"
    sio.write template.epilog + "\n"
    sio.string
  end

  def render_sheets(template:)
    @sheets.map { |sheet| "% #{sheet.title} #{sheet.index}\n" + template.render(sheet.parse).to_s}.join("\n")
  end
end


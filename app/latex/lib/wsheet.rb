# class representing one worksheet
class Worksheet
  attr_reader :wsheet, :index

  def initialize(wsheet:, index:)
    @wsheet = wsheet
    @index = index
  end

  def rows
    @rows ||= normalize_rows
  end

  def normalize_rows
    rows = wsheet['rows'].map { |row| row.map { |cell| escape(cell.to_s.strip) }}
    rows.each { |row| row.pop while !row.empty? && row.last.empty? }
    rows = rows.reject { |row| row.length.zero? }
    rows[0] = rows[0][0..0]
    rows
  end

  def title
    @title ||= wsheet['title']
  end

  def options
    @options ||= wsheet['rows'][0][1..-1]
  end

  def category
    @category ||= find_category
  end

  def categories
    %w[bio chrono list table]
  end

  def escape(str)
    table = {
      # "\n" => "\\\\\n",
      # '&' => '\\&',
      # '%' => '\\%',
      '$' => '\\$',
      # '#' => '\\#',
      # '_' => '\\_', '{' => '\\{', '}' => '\\}',
      # '~' => '\\textasciitilde', '^' => '\\\textasciicircum', '\\' => '\\textbackslash'
    }
    str.chars.map { |c| table.fetch(c, c) }.join('')
  end

  def heading
    rows[0][0]
  end

  def content
    rows[1..-1]
  end

  def column(nth)
    content.map { |row| row[nth] }
  end

  # return true is string looks like a date (or range of dates)
  def date?(str)
    year_regexp = [/^(19|20)[0-9][0-9]$/,	/^(19|20)[0-9][0-9](-|\u2013|\u2014|to).*/]
    str.delete(' ').match?(Regexp.union(year_regexp))
  end

  def bio_data
    {'name' => heading, 'other' => content}
  end

  def chrono_data
    rows.map { |row| row.length == 1 ? row : [row[0], row[1..-1].join(' ')] }
  end

  def list_data
    if option?('number')
      data = rows.map.each_with_index do |row, index|
        row[0][0] == '#' ? "\n#{row[0]}" : "#{index+1}. #{row.join(' ')}"
      end
    elsif option?('reverse')
      data = rows.map.each_with_index do |row, index|
        row[0][0] == '#' ? "\n#{row[0]}" : "#{rows.length - index}. #{row.join(' ')}"
      end
    else
      data = rows.map.each_with_index do |row, index|
        row[0][0] == '#' ? "\n#{row[0]}" : "\n\n#{row.join(' ')}"
      end
    end
    data.join("\n")
  end

  def table_data
    rows
  end

  def option?(option)
    options.map(&:downcase).include? option.downcase
  end

  def ncolumns
    rows[1..-1].map(&:length).max
  end

  def inspect
    "Sheet - chrono?: #{chrono?} - columns: #{ncolumns} - options: #{options}"
  end

  def find_category
    categories.each do |cat|
      return cat if send("#{cat}?")
    end
    'unknown'
  end

  def data
    send("#{category}_data")
  end

  def bio?
    @index.zero?
  end

  def table?
    return false if @index == 0
    return false if chrono?
    ncolumns >= 2
  end

  def list?
    return false if @index.zero?

    ncolumns == 1
  end

  def chrono?
    return false if @index.zero?

    column(0).reject(&:empty?).map { |cell| date?(cell) }
             .then { |dates| dates.count(true) >= dates.length / 2}
  end
end

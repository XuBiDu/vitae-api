# class representing one worksheet
class Worksheet
	attr_reader :title, :rows, :index
	
	def initialize(wsheet:, index:)
		@title = wsheet['title']
		@rows = wsheet['rows'].map { |row| row.map { |cell| escape(cell.to_s.strip) }}
		@rows.each { |row| row.pop while !row.empty? && row.last.empty? }
		@rows = @rows.reject { |row| row.length.zero? }
		@index = index
	end
	
	def escape(str)
		table = {
		# "\n" => "\\\\\n",
		# '&' => '\\&', 
		'%' => '\\%', 
		'$' => '\\$', 
		# '#' => '\\#',
		# '_' => '\\_', '{' => '\\{', '}' => '\\}',
		# '~' => '\\textasciitilde', '^' => '\\\textasciicircum', '\\' => '\\textbackslash'
		}
		str.chars.map { |c| table.fetch(c, c) }.join('')
	end

	def heading
		@rows[0][0]
	end

	def title
		heading
	end

	def options
		@rows[0][1..-1]
	end

	def data
		@rows[1..-1]
	end

	def column(nth)
		data.map {|row| row[nth]}
	end
	# return true is string looks like a date (or range of dates)
	def date?(str)
		year_regexp = [/^(19|20)[0-9][0-9]$/,	/^(19|20)[0-9][0-9](-|\u2013|\u2014|to).*/]
		str.delete(' ').match?(Regexp.union(year_regexp))
	end

	def bio?
		@index == 0
	end

	def bio
		{'name' => heading, 'other' => data}
	end
	
	def chrono?
		return false if @index == 0
		column(0).reject(&:empty?).map { |cell| date?(cell) }
		.then { |dates| dates.count(true) >= dates.length / 2}
	end
	
	def chrono
		rows.map { |row| row.length == 1 ? row : [row[0], row[1..-1].join(' ')] }
	end
	
	def list?
		return false if @index == 0
		columns == 1
	end

	def list
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
	
	def table?
		return false if @index == 0
		return false if chrono?
		columns >= 2
	end

	def table
		rows
	end
	
	def option?(option)
		options.map(&:downcase).include? option.downcase
	end
	
	def columns
		rows[1..-1].map(&:length).max
	end
	
	def inspect
		"Sheet - chrono?: #{chrono?} - columns: #{columns} - options: #{options}"
	end
	
	def parse
		if bio?
			{'bio' => bio}
		elsif chrono?
			{'chrono' => chrono}
		elsif list?
			{'list' => list}
		elsif table?
			{'table' => table}
		else
			raise 'Unknown sheet type'
		end
	end
end

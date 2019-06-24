# frozen_string_literal: true
require 'kramdown'

# Plasmati template
class Plasmati
  attr_reader :sheets

  def initialize(sheets: )
    @sheets = sheets
  end

  def self.template_files
    'plasmati'
  end

  def self.engine
    'xelatex'
  end

  def render
    [prolog, render_sheets, epilog].join("\n")
  end

  private

  def kram(text:)
    kram_opts = {'latex_headers' => ['section*','subsection*','subsubsection*','paragraph','subparagraph*','subparagraph*']}
    Kramdown::Document.new(text, kram_opts).to_latex.strip.gsub(/(Ph.D.|PhD|MSc|M.Sc.)/, '\\textsc{\1}')
  end

  def render_sheets
    sheets.map do |sheet|
      "% #{sheet.title} #{sheet.index}\n" + render_sheet(sheet: sheet).to_s
    end.join("\n")
  end

  def render_sheet(sheet:)
    categories = %w[bio list chrono table]
    category = sheet.category
    return "% unknown category #{category}" unless categories.include? category

    send(category, data: sheet.data)
  end

  def bio(data:)
    name = data['name']
    other = data['other']

    out = <<~HEREDOC
      \\par{\\centering      {\\Huge \\textsc{#{name}}    }\\bigskip\\par}
      \\font\\fb=''[cmr10]'' %for use with \\LaTeX command
      \\section{Personal Data}
      \\begin{minipage}[c]{0.5\\textwidth}
      \n\\begin{supertabular}{rr}
    HEREDOC

    other.each do |row|
      if row.length == 1 then
        out += "& #{row[0]}\\\\\n"
      else
        key = row[0]
        value = kram(text: row[1..-1].join(' '))
        if isemail? key
          out += " &  \\href{mailto:#{value}}{#{value}}\\\\\n"
        elsif isurl? key
          out += " & \\href{#{value}}{#{value}}\\\\\n"
        elsif isphone? key
          out += " &  \\texttt{#{value}}\\\\\n"
        else
          out += " & #{value}\\\\\n"
        end
      end
    end
    out += <<~HEREDOC
      \\end{supertabular}
      \\end{minipage}
      \\begin{minipage}[c]{0.5\\textwidth}
      \\includegraphics[width=5cm]{photo.jpg}
      \\end{minipage}
    HEREDOC
  end

  def isemail?(key)
    ['email', 'e-mail'].include? key.downcase
  end

  def isurl?(key)
    %w[url webpage 'web page' homepage 'home page' website 'web site'].include? key.downcase
  end

  def isphone?(key)
    %w[phone fax telephone facsimile].include? key.downcase
  end

  def chrono(data:)
    data.slice_when{ |i, j| i.length != j.length || i.length == 1}.to_a.map do |slice|
      slice.length == 1 && slice[0].length == 1 ? header(row: slice[0]) : table_2(rows: slice)
    end.join("\n")
  end

  def header(row:)
    kram(text: row.join(' '))
  end

  def table_2(rows:)
    [table_header_2, rows_2(rows: rows), table_footer].join("\n")
  end

  def rows_2(rows:)
    rows.map { |row| row_2(row: row)}.join("\n")
  end

  def row_2(row:)
    '\\textsc{' + kram(text: row[0]) + '} & ' + kram(text: row[1]) + '\\\\'
  end

  def table_header_2
    "\n\\begin{supertabular}{lp{10cm}}"
  end

  def table_footer
    "\\end{supertabular}\n"
  end

  def list(data:)
    kram(text: data)
  end

  def table(data:)
    data.slice_when{ |i, j| i.length != j.length || i.length == 1}.to_a.map do |slice|
      slice.length == 1 && slice[0].length == 1 ? header(row: slice[0]) : table_n(rows: slice)
    end.join("\n")
  end

  def table_n(rows:)
    widths = rows.map { |row| row.map(&:length) }
                 .transpose.map(&:sum)
                 .then { |sums| sums.map{ |value| value.to_f / sums.sum }}
    [table_header_n(widths: widths, header: rows[0]),
     rows_n(rows: rows[1..-1]),
     table_footer].join("\n")
  end

  def table_header_n(widths:, header:)
    ws = widths.map{ |w| 'p{' + (w * 10).round(2).to_s + 'cm}' }.join('')
    hd = header.map { |cell| "\\textsc{#{cell}}" }.join(" & ")
    "\n\\begin{supertabular}{#{ws}}\n#{hd}\\\\ \\hline"
  end

  def rows_n(rows:)
    rows.map { |row| row_n(row: row)}.join("\n")
  end

  def row_n(row:)
    row.map { |cell| kram(text: cell) }.join(' & ') + '\\\\'
  end

  def prolog
    <<~HEREDOC
      \\documentclass[a4paper,10pt]{article}

      %A Few Useful Packages
      \\usepackage{marvosym}
      \\usepackage{fontspec} 					%for loading fonts
      \\usepackage{xunicode,xltxtra,url,parskip} 	%other packages for formatting
      \\RequirePackage{color,graphicx}
      \\usepackage[usenames,dvipsnames]{xcolor}
      \\usepackage[big]{layaureo} 				%better formatting of the A4 page
      % an alternative to Layaureo can be ** \\usepackage{fullpage} **
      \\usepackage{supertabular} 				%for Grades
      \\usepackage{titlesec}					%custom \\section

      %Setup hyperref package, and colours for links
      \\usepackage{hyperref}
      \\definecolor{linkcolour}{rgb}{0,0.2,0.6}
      \\hypersetup{colorlinks,breaklinks,urlcolor=linkcolour, linkcolor=linkcolour}

      %FONTS
      \\defaultfontfeatures{Mapping=tex-text}
      %\\setmainfont[SmallCapsFont = Fontin SmallCaps]{Fontin}
      %%% modified for Karol Kozioł for ShareLaTeX use
      \\setmainfont[
      SmallCapsFont = Fontin-SmallCaps.otf,
      BoldFont = Fontin-Bold.otf,
      ItalicFont = Fontin-Italic.otf,
      Scale=0.9
      ]
      {Fontin.otf}
      %%%

      %CV Sections inspired by:
      %http://stefano.italians.nl/archives/26
      \\titleformat{\\section}{\\Large\\scshape\\raggedright}{}{0em}{}[\\titlerule]
      \\titlespacing{\\section}{0pt}{3pt}{3pt}
      %Tweak a bit the top margin
      %\\addtolength{\\voffset}{-1.3cm}

      %Italian hyphenation for the word: ''corporations''
      \\hyphenation{im-pre-se}

      %-------------WATERMARK TEST [**not part of a CV**]---------------
      \\usepackage[absolute]{textpos}

      \\setlength{\\TPHorizModule}{30mm}
      \\setlength{\\TPVertModule}{\\TPHorizModule}
      \\textblockorigin{2mm}{0.65\\paperheight}
      \\setlength{\\parindent}{0pt}

      %--------------------BEGIN DOCUMENT----------------------

      \\font\\fb=''[cmr10]'' %for use with \\LaTeX command

      \\begin{document}
    HEREDOC
  end

  def epilog
    '\\end{document}'
  end
end

require 'kramdown'

class Plasmati
  def self.kram(text:)
    kram_opts = {'latex_headers' => ['section*','subsection*','subsubsection*','paragraph','subparagraph*','subparagraph*']}
    Kramdown::Document.new(text, kram_opts).to_latex.strip.gsub(/(Ph.D.|PhD|MSc|M.Sc.)/, '\\textsc{\1}')
  end

  def self.dir
    'plasmati'
  end

  def self.engine
    'xelatex'
  end

  def self.bio(data:)
    name = data['name']
    other = data['other']

    out = "\\par{\\centering      {\\Huge \\textsc{#{name}}    }\\bigskip\\par}\n"
    out += "\\font\\fb=''[cmr10]'' %for use with \\LaTeX command\n"
    out += "\\section{Personal Data}\n"
    out += "\\begin{minipage}[c]{0.5\\textwidth}\n"
    out += "\n\\begin{supertabular}{rr}\n"

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
    out += "\\end{supertabular}\n\n"
    out += "\\end{minipage}\n"
    out += "\\begin{minipage}[c]{0.5\\textwidth}\n"
    out += "\\includegraphics[width=5cm]{photo.jpg}\n"
    out += "\\end{minipage}\n"
    out
  end

  def self.isemail?(key)
    ['email', 'e-mail'].include? key.downcase
  end

  def self.isurl?(key)
    ['url', 'webpage', 'web page', 'homepage', 'home page', 'website', 'web site'].include? key.downcase
  end

  def self.isphone?(key)
    ['phone', 'fax', 'telephone', 'facsimile'].include? key.downcase
  end

  def self.render(type_and_data)
    method, data = type_and_data.first
    return unless ['bio', 'list', 'chrono', 'table'].include? method
    send(method, data: data)
  end

  def self.chrono(data:)
    data.slice_when{ |i, j| i.length != j.length || i.length == 1}.to_a.map do |slice|
      slice.length == 1 && slice[0].length == 1 ? header(row: slice[0]) : table_2(rows: slice)
    end.join("\n")
  end

  def self.header(row:)
    kram(text: row.join(' '))
  end

  def self.table_2(rows:)
    [table_header_2, rows_2(rows: rows), table_footer].join("\n")
  end

  def self.rows_2(rows:)
    rows.map { |row| row_2(row: row)}.join("\n")
  end

  def self.row_2(row:)
    '\\textsc{' + kram(text: row[0]) + '} & ' + kram(text: row[1]) + '\\\\'
  end

  def self.table_header_2
    "\n\\begin{supertabular}{lp{10cm}}"
  end

  def self.table_footer
    "\\end{supertabular}\n"
  end

  def self.list(data:)
    kram(text: data)
  end

  def self.table(data:)
    data.slice_when{ |i, j| i.length != j.length || i.length == 1}.to_a.map do |slice|
      slice.length == 1 && slice[0].length == 1 ? header(row: slice[0]) : table_n(rows: slice)
    end.join("\n")
  end

  def self.table_n(rows:)
    widths = rows.map { |row| row.map(&:length) }
                 .transpose.map(&:sum)
                 .then { |sums| sums.map{ |value| value.to_f / sums.sum }}
    [table_header_n(widths: widths, header: rows[0]),
     rows_n(rows: rows[1..-1]),
     table_footer].join("\n")
  end

  def self.table_header_n(widths:, header:)
    ws = widths.map{ |w| 'p{' + (w * 10).round(2).to_s + 'cm}' }.join('')
    hd = header.map { |cell| "\\textsc{#{cell}}" }.join(" & ")
    "\n\\begin{supertabular}{#{ws}}\n#{hd}\\\\ \\hline"
  end

  def self.rows_n(rows:)
    rows.map { |row| row_n(row: row)}.join("\n")
  end

  def self.row_n(row:)
    row.map { |cell| kram(text: cell) }.join(' & ') + '\\\\'
  end

  def self.prolog
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

  def self.epilog
    "\\end{document}"
  end
end

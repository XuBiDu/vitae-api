require 'kramdown'

class Taraborelli
  def self.kram(text:)
    kram_opts = {'latex_headers' => ['section*','subsection*','subsubsection*','paragraph','subparagraph*','subparagraph*']}
    Kramdown::Document.new(text, kram_opts).to_latex.gsub(/(Ph.D.|PhD|MSc|M.Sc.)/, '\\textsc{\1}')
  end

  def self.dir
    'taraborelli'
  end

  def self.bio(data:)
    name = data['name']
    other = data['other']
    out = pdf_preamble(name: name)
    out += "\\begin{document}\n"
    out += "{\\LARGE #{name}}\\\\[1cm]\n"
    other.each do |row|
      if row.length == 1 then
        out += "#{row[0]}\\\\\n"
      else
        key = row[0]
        value = kram(text: row[1..-1].join(' '))
        if isemail? key
          out += "\\href{mailto:#{value}}{#{value}}\\\\\n"
        elsif isweb? key
          out += "\\href{#{value}}{#{value}}\\\\\n"
        elsif isphone? key
          out += "\\texttt{#{value}}\\\\\n"
        else
          out += "#{value}\\\\\n"
        end
      end
    end
    out += "\\vfill\n"
    out
  end

  def self.isemail?(key)
    ['email', 'e-mail'].include? key.downcase
  end

  def self.isweb?(key)
    ['url', 'webpage', 'web page', 'homepage', 'home page', 'website', 'web site'].include? key.downcase
  end

  def self.isphone?(key)
    ['phone', 'fax', 'telephone', 'facsimile'].include? key.downcase
  end

  def self.render(type_and_data)
    method, data = type_and_data.first
    return unless ['bio', 'list', 'chrono'].include? method
    send(method, data: data)
  end

  def self.chrono(data:)
    out = ''
    data.each do |row|
      if row[0][0] == '#'
        out += kram(text: row[0])
      else
        contents = kram(text: row[1..-1].join(', '))
        if row[0].empty?
          out += contents + "\\\\\n"
        else
          out += "\\years{#{row[0]}}#{contents}" + "\\\\\n"
        end
      end
    end
    out + "\n"
  end

  def self.list(data:)
    kram(text: data)
  end

  def self.table(data:)
    # out = ''
    # out += "\\section*{#{data[0][0]}}\n"
    # state = 'newtable'
    # data.each do |row|
    #   if row.length == 1
    #     if state == 'intable'
    #       out += "\n\\end{tabular}\n"
    #       out += "\\end{center}\n"
    #     end
    #     out += "\\subsection*{#{row[0]}}\n"
    #     state = 'newtable'
    #   else # normal row
    #     if state == 'newtable'
    #       out += "\\begin{center}\n"
    #       cells = row.length
    #       width = (1.0/cells).round(2).to_s
    #       columns = "p{#{width}\\linewidth}" * cells
    #       out += "\\begin{tabular}{#{columns}}\n"
    #       out += row.map { |cell| "\\textsc{#{cell}}" }.join(' & ') + "\n\\midrule\n"
    #       state = 'intable'
    #     else
    #       out += "\\\\\n"
    #       out += row.join(' & ')
    #     end
    #   end
    # end
    # out += "\n\\end{tabular}\n"
    # out += "\\end{center}\n"
    # out
  end

  def self.prolog
    <<~HEREDOC
      %------------------------------------
      % Dario Taraborelli
      % Typesetting your academic CV in LaTeX
      %
      % URL: http://nitens.org/taraborelli/cvtex
      % DISCLAIMER: This template is provided for free and without any guarantee
      % that it will correctly compile on your system if you have a non-standard
      % configuration.
      % Some rights reserved: http://creativecommons.org/licenses/by-sa/3.0/
      %------------------------------------

      %!TEX TS-program = xelatex
      %!TEX encoding = UTF-8 Unicode

      \\documentclass[10pt, a4paper]{article}
      \\usepackage{fontspec}

      % DOCUMENT LAYOUT
      \\usepackage{geometry}
      \\geometry{a4paper, textwidth=5.5in, textheight=8.5in, marginparsep=7pt, marginparwidth=.6in}
      \\setlength\\parindent{0in}
      % FONTS
      \\usepackage[usenames,dvipsnames]{xcolor}
      \\usepackage{xunicode}
      \\usepackage{xltxtra}
      \\defaultfontfeatures{Mapping=tex-text}
      %\\setromanfont [Ligatures={Common}, Numbers={OldStyle}, Variant=01]{Linux Libertine O}
      %\\setmonofont[Scale=0.8]{Monaco}
      %%% modified by Karol Kozioł for ShareLaTeX use
      \\setmainfont[
        Ligatures={Common}, Numbers={OldStyle}, Variant=01,
        BoldFont=LinLibertine_RB.otf,
        ItalicFont=LinLibertine_RI.otf,
        BoldItalicFont=LinLibertine_RBI.otf
      ]{LinLibertine_R.otf}
      \\setmonofont[Scale=0.8]{DejaVuSansMono.ttf}

      % ---- CUSTOM COMMANDS
      \\chardef\\&="E050
      \\newcommand{\\html}[1]{\\href{#1}{\\scriptsize\\textsc{[html]}}}
      \\newcommand{\\pdf}[1]{\\href{#1}{\\scriptsize\\textsc{[pdf]}}}
      \\newcommand{\\doi}[1]{\\href{#1}{\\scriptsize\\textsc{[doi]}}}
      % ---- MARGIN YEARS
      \\usepackage{marginnote}
      \\newcommand{\\amper{}}{\\chardef\\amper="E0BD }
      \\newcommand{\\years}[1]{\\marginnote{\\scriptsize #1}}
      \\renewcommand*{\\raggedleftmarginnote}{}
      \\setlength{\\marginparsep}{7pt}
      \\reversemarginpar

      % HEADINGS
      \\usepackage{sectsty}
      \\usepackage[normalem]{ulem}
      \\sectionfont{\\mdseries\\upshape\\Large}
      \\subsectionfont{\\mdseries\\scshape\\normalsize}
      \\subsubsectionfont{\\mdseries\\upshape\\large}

    HEREDOC
  end

  def self.epilog
    <<~HEREDOC
      \\end{document}
    HEREDOC
  end

  def self.pdf_preamble(name:)
    <<~HEREDOC

      % PDF SETUP
      % ---- FILL IN HERE THE DOC TITLE AND AUTHOR
      \\usepackage[%dvipdfm,
      bookmarks, colorlinks, breaklinks,
      % ---- FILL IN HERE THE TITLE AND AUTHOR
        pdftitle={#{name} - vita},
        pdfauthor={VitaeVitae},
        pdfproducer={https://vitae2.herokuapp.com}
      ]{hyperref}
      \\hypersetup{linkcolor=blue,citecolor=blue,filecolor=black,urlcolor=MidnightBlue}
    HEREDOC
  end
end

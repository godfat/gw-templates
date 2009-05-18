#encoding: utf-8

# spec from: http://guildwars.wikia.com/wiki/Skill_template_format

module GW
  class TemplateReader
    Template = {14 => 'Skills'}
    Profession = %w[None Warrior Ranger Monk Necromancer Mesmer Elementalist Assassin Ritualist Paragon Dervish]
    Attributes = File.read(File.join(File.dirname(__FILE__), 'code_attributes.txt')).split("\n")
    Skills     = File.read(File.join(File.dirname(__FILE__), 'code_skills.txt'    )).split("\n")

    attr_reader(:code, :template, :version, :primary, :secondary, :attributes, :skills)

    def initialize code
      @code = code.dup.freeze
      @data = code.unpack('m*').first.unpack('B*').first.scan(/\d{6}/).map(&:reverse).join

      @template  = extract!(4)
      @version   = extract!(4)
      bits_pro   = extract!(2) * 2 + 4
      @primary   = extract!(bits_pro)
      @secondary = extract!(bits_pro)

      attrs      = extract!(4)
      bits_att   = extract!(4) + 4
      @attributes = []
      attrs.times{
        @attributes << [extract!(bits_att), extract!(4)]
      }

      bits_ski   = extract!(4) + 8
      @skills = []
      8.times{
        @skills << extract!(bits_ski)
      }
    end

    def display o = $stdout
      o.puts("  Template: #{Template[template]}")
      o.puts("   Version: #{version}")
      o.puts("      Code: #{code}")
      o.puts("Profession: #{Profession[primary]} / #{Profession[secondary]}")
      o.puts
      o.puts("Attributes:")
      @attributes.each{ |attribute|
        o.puts("%20s %2d" % [Attributes[attribute.first], attribute.last])
      }
      o.puts
      o.puts("    Skills:")
      8.times{ |i|
        o.puts("%23s" % Skills[@skills[i]][5..-1])
      }
    end

    def display_snippet o = $stdout
      require 'stringio'
      sio = StringIO.new
      display(sio)
      o.puts(add_wiki_link(remove_leading_spaces(sio.string)))
    end

    def display_xhtml o = $stdout
      require 'stringio'
      sio = StringIO.new
      display(sio)
      o.puts(add_br_newline(add_wiki_link(remove_leading_spaces(sio.string))))
    end

    private
    def extract! n; @data.slice!(0, n).reverse.to_i(2);   end
    def remove_leading_spaces s; s.gsub(/^ +/, '');       end
    def add_br_newline        s; s.gsub("\n", "<br/>\n"); end

    def add_wiki_link s
      r = s.split(/Skills:/)
      r.first + "Skills:" + r.last.gsub(/([^\n]+)/){
        "<a href=\"http://guildwars.wikia.com/wiki/#{$1}\">#{$1}</a>"
      }
    end
  end
end

require 'optparse'

argv = ARGV.dup
opts = {}
parser = OptionParser.new{ |parser|
  parser.banner  = "Usage: ruby #{__FILE__} [options] [files]"
  parser.version = '1.0'

  msg_h = 'Show this message'
  msg_i = 'Read from stdin'
  msg_t = 'Output text (default)'
  msg_s = 'Output xhtml snippet (for forum/blog post)'
  msg_p = 'Output xhtml page'

  parser.on('-h', '--help',    msg_h){ puts(parser); exit }
  parser.on('-i', '--stdin',   msg_i){ |o| opts[:i] = o }
  parser.on('-t', '--text',    msg_t){ |o| opts[:t] = o }
  parser.on('-s', '--snippet', msg_s){ |o| opts[:s] = o }
  parser.on('-p', '--page',    msg_p){ |o| opts[:p] = o }
}
parser.parse!

if argv.empty?
  puts(parser)

else
  input = nil
  if opts[:i]
    input = [['/dev/stdin', $stdin.read]]
  else
    input = ARGV.map{ |file| [file, File.read(file)] }
  end

  if opts[:s]
    input.each{ |i|
      puts("<h1> #{i.first}:</h1>")
      GW::TemplateReader.new(i.last).display_snippet
      puts('<hr/>')
    }

  elsif opts[:p]
    puts <<-XHTML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
  <head profile="http://www.w3.org/2005/10/profile">
    <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
    <title>Guild Wars Skills Template Reader</title>
  </head>
  <body>
    <div>
XHTML

    input.each{ |i|
      puts("<h1> #{i.first}:</h1>")
      GW::TemplateReader.new(i.last).display_xhtml
      puts('<hr/>')
    }

    puts <<-XHTML
    </div>
  </body>
</html>
XHTML


  else
    input.each{ |i|
      puts("== #{i.first}:")
      GW::TemplateReader.new(i.last).display
      puts('-' * 25)
    }

  end
end

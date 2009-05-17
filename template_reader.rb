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

    def display
      puts("  Template: #{Template[template]}")
      puts("   Version: #{version}")
      puts("Profession: #{Profession[primary]} / #{Profession[secondary]}")
      puts
      puts("Attributes:")
      @attributes.each{ |attribute|
        puts("%20s %2d" % [Attributes[attribute.first], attribute.last])
      }
      puts
      puts("    Skills:")
      8.times{ |i|
        puts("%23s" % Skills[@skills[i]][5..-1])
      }
    end

    private
    def extract! n
      @data.slice!(0, n).reverse.to_i(2)
    end
  end
end

GW::TemplateReader.new($stdin.read).display

#encoding: utf-8

module GW
  class TemplateReader
    Template = {14 => 'Skills'}
    Profession = %w[None Warrior Ranger Monk Necromancer Mesmer Elementalist Assassin Ritualist Paragon Dervish]

    attr_reader(:code, :template, :version, :primary, :secondary)

    def initialize code
      @code = code.dup.freeze
      @data = code.unpack('m*').first.unpack('B*').first.scan(/\d{6}/).map(&:reverse).join

      @template  = extract!(4)
      @version   = extract!(4)
      bits       = extract!(2) * 2 + 4
      @primary   = extract!(bits)
      @secondary = extract!(bits)
    end

    def display
      puts("  Template: #{Template[template]}")
      puts("   Version: #{version}")
      puts("Profession: #{Profession[primary]} / #{Profession[secondary]}")
    end

    private
    def extract! n
      @data.slice!(0, n).reverse.to_i(2)
    end
  end
end

GW::TemplateReader.new(File.read(ARGV.first)).display

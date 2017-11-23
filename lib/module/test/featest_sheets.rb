# encoding: utf-8
=begin

   Module principal de test qui contient les données des feuilles
   de featest.

=end
module FeaTestModule
  class FeaTestSheet

    ETAPES      = Hash.new
    USER_TYPES  = Hash.new

    class << self

      # Méthode principale qui procède à l'analyse des feuilles de
      # featest.
      def analyze_sheets(folder)
        Dir["#{folder}/**/*.ftest"].each do |fpath|
          key = File.basename(fpath,File.extname(fpath)).to_sym
          ETAPES.merge!(key => new(fpath))
          ETAPES[key].parse
        end

        puts "ETAPES : #{ETAPES.inspect}"
        puts "USER_TYPES: #{USER_TYPES.inspect}"
        if ETAPES.empty?
          error "Aucune feuille de test FeaTest n'a été trouvé dans `#{folder}`…"
          exit 1
        end
      end

    end #/<< self

    # --------------------------------------------------------------------------------
    #
    #    INSTANCE FeaTestModule::FeaTestSheet
    # 
    # --------------------------------------------------------------------------------

    attr_reader :path
    def initialize fpath
      @path = fpath
    end

    # Méthode principale qui parle une feuille FeaTest pour en tirer les 
    # données de test.
    def parse
      current_utype = nil
      File.open(path).readlines.each do |line|
        line = line.strip
        line.start_with?(':') && next # commentaire
        line.gsub(/[-=]/,'') != '' || next # soulignement
        puts "line: #{line}"
        case line
        when /\* ([\-\+])/
          case $1
          when '-' then USER_TYPES[current_utype].merge!(can_not_act_as_next: true)
          when '+' then USER_TYPES[current_utype].merge!(can_act_as_previous: true)
          end
        when /^as: ?(.*?)(?:---(.*))?$/i
          # Définition d'un nouvel utilisateur
          utype = ($1||'').strip.downcase.to_sym
          desc  = ($2||'').strip
          USER_TYPES.key?(utype) || USER_TYPES.merge!(
            utype => {description: desc, type: utype, features: Array.new, 
                      previous_user: current_utype, next_user: nil}
          )
          current_utype && USER_TYPES[current_utype].merge!(next_user: utype)
          current_utype = utype
        when /^\* (.*)---(.*)$/
          USER_TYPES[current_utype][:features] << {hname: $1.strip, affixe: $2.strip} 
        end
      end
    end
  end #/FeaTestSheet
end#/module 

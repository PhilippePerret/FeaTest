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

        #puts "ETAPES : #{ETAPES.inspect}"
        #puts "USER_TYPES: #{USER_TYPES.inspect}"
        if ETAPES.empty?
          error "Aucune feuille de test FeaTest n'a été trouvé dans `#{folder}`…"
          exit 1
        end
      end

    end #/<< self

  end #/FeaTestSheet
end#/module 


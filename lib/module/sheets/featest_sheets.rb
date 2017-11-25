# encoding: utf-8
=begin

   Module principal de test qui contient les données des feuilles
   de featest.

=end
module FeaTestModule
  class FeaTestSheet

    # Toutes les "steps", les étapes ou les sections du site ou de l'application
    ETAPES      = Hash.new

    # Contiendra tous les users types récoltés dans chaque featest sheet, contrairement
    # à la propriété per_user_types qui correspond à une sheet en particulier.
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


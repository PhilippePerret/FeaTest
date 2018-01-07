# encoding: utf-8
=begin

   Module principal de test qui contient les données des feuilles
   de featest.

=end
module FeaTestModule
  class FeaTestSheet

    class << self

      # Toutes les "steps", les étapes ou les sections du site ou de l'application
      # Elles sont récoltées dans les sheets .ftest
      #
      # Note test : pour avoir accès à ces propriétés, puisqu'elles se trouvent
      # définies dans un module, il faut le requérir par
      # `require_module('sheets')`
      def sheets_steps
        @sheets_steps ||= Hash.new
      end
      # (surtout pour les tests de featest)
      def sheets_steps= value ; @sheets_steps = value end

      # Contiendra tous les users types récoltés dans chaque featest sheet, contrairement
      # à la propriété per_user_types qui correspond à une sheet en particulier.
      #
      # Cf. la note ci-dessus pour les tests.
      def users_types
        @users_types ||= Hash.new
      end
      # (surtout pour les tests de featest)
      def users_types= value ; @users_types = value end


      # Méthode principale qui procède à l'analyse des feuilles de
      # featest.
      def analyze_sheets(folder)
        Dir["#{folder}/**/*.ftest"].each do |fpath|
          key = File.basename(fpath,File.extname(fpath)).to_sym
          sheets_steps.merge!(key => new(fpath))
          sheets_steps[key].parse
        end

        #puts "sheets_steps: #{sheets_steps.inspect}"
        #puts "users_types: #{users_types.inspect}"
        if sheets_steps.empty?
          raise "Aucune feuille de test FeaTest n'a été trouvé dans `#{folder}`…"
        end
      end

    end #/<< self

  end #/FeaTestSheet
end#/module

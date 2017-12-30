# encoding: utf-8
module FeaTestModule
  class FeaTestSheet
    class << self

      # La somme d'erreurs de chaque feuille, principalement pour les
      # tests.
      attr_reader :errors_count

      # Procédure principale qui va checker les feuilles de test et 
      # les corriger au cas où.
      # "Checker les feuilles de test" consiste principalement à
      # s'assurer que tous les fichiers de feature-code existent et,
      # si la commande ou l'option `build` est définie, de les
      # construire pour les coder.
      def check

        @errors_count = 0
        
        # Est-ce que c'est pour une construction ou un simple check
        for_building = CLI.param(2) == 'build' || !!CLI.option(:build)
        simple_check = !for_building
        puts "MODE : #{simple_check ? 'SIMPLE CHECK' : 'FABRICATION DES FICHIERS MANQUANTS'}"

        # On commence par analyser les fichiers .ftest
        analyze_sheets(FeaTest.current.sheets_folder)
    
        # Boucle sur chaque feuille featest (.ftest)
        # Si `--steps` a été déterminé, on ne boucle que sur ces étapes
        # sinon, on boucle sur toutes.
        #puts "steps = #{FeaTest.current.steps.inspect}"

        # Pour consigner les étapes qui seront passées, afin de les signaler
        # en fin de processus.
        etapes_passees = Array.new

        # Entête du tableau de rapport
        header_line = line_check_report(['PATH', 'TYPE', 'EXIST', 'CODE'])
        delim = "-"*header_line.length
        puts delim
        puts header_line
        puts delim

        # Boucle sur chaque step, donc chaque feuille .ftest
        sheets_steps.each do |ketape, etape|
          if FeaTest.current.steps.include?(ketape) 
            @errors_count += etape.check(build: for_building)
          else
            etapes_passees << ketape
          end
        end

        puts delim
        puts "NOTES\n-----"
        puts "    * La colonne CODE indique si le fichier contient réellement du code."
        unless CLI.option(:error_only)
          puts "    * Pour ne voir que les erreurs, ajouter l'option `--error-only`."
        end
        puts "\n"

        # Indication des étapes qui n'ont pas été traitées,
        # if any.
        unless etapes_passees.empty?
          puts "Ces étapes ont été passées : #{etapes_passees.join(', ')}"
        end

        if for_building
          puts "\n\n"
          notice "Tous les fichiers ont été créés avec succès."
          puts "\n\n"
        end

        return errors_count
      end
      #/check


      # Retourne la ligne de rapport
      def line_check_report data
        s = String.new
        s << ''.ljust(2)
        s << data[0].to_s.ljust(100) # Path du fichier
        s << okOrNot(data[2])        # Existence du fichier
        s << data[1].to_s.ljust(6)   # Type du fichier (FILE/FEAT)
        s << okOrNot(data[3])        # Contient bien du code ou non
        s << ''.ljust(2)
        return s
      end
      def okOrNot value
        case value
        when NilClass then ''
        when String   then value
        else value ? " \033[44mOK\033[0m   " : " \033[41mNO\033[0m   "
        end.ljust(6)
      end


    end #/<< self
  end #/FeaTestSheet
end #/FeaTestModule

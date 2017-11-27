# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    # Retourne le code des tests de l'étape pour l'user de
    # type +utype+ pour l'étape courante.
    #
    # C'est dans cette méthode qu'on détermine tous les 
    # features qui doivent être testés et contre-testés en
    # fonction du type de l'user +utype+.
    #
    def full_test_code_for utype
      dfeatures = per_user_types[utype]
      dfeatures || (return nil) # quand il n'y a rien pour ce type d'user

      dossier = self.steps_folder(utype)
      __dg("Dossier codes pour step #{self.step.inspect} et user #{utype.inspect}: #{dossier.inspect}",5)

      paths = Array.new
      
      paths = paths_tests_can_for(utype, paths)
      __dg("Paths pour CAN : #{paths.inspect}", 3)

      paths = paths_tests_can_not_for(utype, paths)
      __dg("Paths (tous) : #{paths.inspect}", 3)

      # On peut récupérer tous les codes
      # Noter que l'existence des fichiers a déjà été traité, et qu'il n'y a dans
      # paths que des fichiers existants.
      #
      # Chaque portion de code est enroulé dans un begin-rescue
      # 
      full_code =
        paths.collect do |path|
          writerpath = "__write_path('#{relative_path path}')\n"
          code = File.read(path).force_encoding('utf-8')

          if code_feature_empty?(code)
            # TODO On met un message d'alerte pour dire qu'il n'y
            # a pas de code
            error "Fichier sans test : #{relative_path path}"
          else
            # Sinon, on peut écrire ce code pour le jouer
            code =
              if code.match(/NEW_SCENARIO/)
              code.gsub(/NEW_SCENARIO/){
                <<-EOC
  #{rescue_de_fin_de_feature_test}
    end # de fin de scénario intercalé
    #{FeaTest.current.entete_scenario_template(self, utype, writerpath)}
    begin #--- begin intercalé
                EOC
              } 
              else
                writerpath + code
              end

            # On le met dans un begin-rescue
            <<-EOC
    #--- FEATURE-CASE #{relative_path path}
      begin
      #{code}
      #{rescue_de_fin_de_feature_test}
            EOC
          end #/ fin de s'il y a vraiment du code à jouer
        end.join("\n\n")

      # On épure le code
      full_code
    end

    # retourne TRUE si le code +code+ ne contient aucun texte. On le vérifie
    # en cherchant, après suppression des commentaires, qu'on trouve le mot
    # `expect`.
    def code_feature_empty? code
      !code.gsub(/#(.*)\n/m,"\n").match(/expect/)
    end

    def designation
      @designation ||=
        begin
          s = step.downcase
          description && s << " (#{description})"
          s
        end
    end
    def rescue_de_fin_de_feature_test
      @rescue_de_fin_de_feature_test ||= FeaTest.current.build_rescue_de_fin_de_feature(self)
    end

    def paths_tests_can_for utype, arr
      dfeatures = per_user_types[utype]
      dfeatures[:features].each do |feat|
        __dg("Ajout de la feature : #{feat.inspect}",4)
        pfeat = File.join(steps_folder(utype),"can_#{feat[:affixe]}.rb")
        __db("Path de la feature : #{pfeat}",5)
        existOrError(pfeat) && arr << pfeat
      end
      if dfeatures[:features_only]
        dfeatures[:features_only].each do |feat|
          __dg("Ajout de la feature 'only' : #{feat.inspect}",4)
          pfeat = File.join(steps_folder(utype),"can_#{feat[:affixe]}.rb")
          __db("Path de la feature 'only' : #{pfeat}",5)
          existOrError(pfeat) && arr << pfeat
        end
      end
      # Le type user précédent
      if dfeatures[:can_act_as_previous]
        __dg("Doit agir comme le précédent : #{dfeatures[:previous_user].inspect}",4)
        arr = paths_tests_can_for(dfeatures[:previous_user], arr)
      end
      return arr
    end

    def paths_tests_can_not_for utype, arr
      dfeatures = per_user_types[utype]
      dossier   = steps_folder(utype)
      if dfeatures[:features_out]
        dfeatures[:features_out].each do |feat|
          __dg("Ajout de la non feature : #{feat.inspect}",5)
          pfeat = File.join(dossier,"CANT_#{feat[:affixe]}.rb")
          __db("Path de la non feature : #{pfeat}",5)
          existOrError(pfeat) && arr << pfeat
        end
      end

      if dfeatures[:can_not_act_as_next]
        __dg("Ne doit pas agir comme le suivant : #{dfeatures[:next_user].inspect}",4)
        # Note : c'est dans le même dossier que le courant, mais avec le préfixe 'CANT_',
        # mais il faut aller "en profondeur".
        next_features = per_user_types[dfeatures[:next_user]]
        next_features[:features].each do |feat|
          # Note : les CANT se trouvent dans le même dossier
          pfeat = File.join(dossier, "CANT_#{feat[:affixe]}.rb")
          existOrError(pfeat) && arr << pfeat
        end
        arr = paths_tests_can_not_for(dfeatures[:next_user], arr)
      end
      return arr
    end

  end#/FeaTestSheet
end #/FeaTestModule

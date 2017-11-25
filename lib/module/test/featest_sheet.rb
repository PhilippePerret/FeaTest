# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    # Retourne le code des tests de l'étape pour l'user de
    # type +utype+
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
      paths.collect do |path|
        # TODO Il faudrait écrire le path
        File.read(path).force_encoding('utf-8')
      end.join("\n\n")
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

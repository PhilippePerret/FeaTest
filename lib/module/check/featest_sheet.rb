# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    attr_reader :options

    def existOrError fpath, type = '    '
      rpath = (FeaTest.current.relpath fpath).ljust(100)
      if File.exist?(fpath)
        notice "- #{rpath} #{type} OK"
      else
        if options[:build]
          # TODO
          "= Fichier #{rpath} construit"
        else
          error("# #{rpath} #{type} KO")
          FeaTest.current.add_aide_required(:fichier_code_test)
        end
      end
    end

    # On teste l'étape +etape+ (instance FeaTestSheet)
    #
    # TODO: Vérifier le contraire, c'est-à-dire que tous les fichiers
    # qui se trouvent dans les dossiers correspondent bien à des features 
    # existantes/définies.
    def check options = Hash.new

      # Les options de check. Définit par exemple qu'il faut construire
      # ce qui doit l'être.
      @options = options

      existOrError(steps_folder, 'file')
      per_user_types.each do |utype,dtype|
        check_utype(utype, dtype)
      end

    end
    #/check

    #
    def check_utype utype, dtype
      existOrError(utype_folder = steps_folder(utype), 'file')
      dtype[:features].each do |feature|
        if feature[:affixe]
          fpath = File.join(utype_folder, "can_#{feature[:affixe]}.rb")
          existOrError(fpath, 'FEAT') 
        else
          error("# La fonctionnalité `#{feature[:hname]}` ne définit pas son affixe (*)")
          FeaTest.current.add_aide_required(:definition_affixe)
        end
      end

      # Contre-fonctionnalités
      if dtype[:can_not_act_as_next]
       per_user_types[dtype[:next_user]][:features].each do |feature|
          fpath = File.join(utype_folder, "CANT_#{feature[:affixe]}.rb")
          existOrError(fpath, 'FEAT') 
        end
      end
    end
    #/check_utype

  end #/FeaTestSheet
end #/FeaTestModule

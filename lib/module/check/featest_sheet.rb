# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    def relpath fpath
      fpath.sub(/^#{FeaTest.current.main_folder}\//,'.')
    end
    def existOrError fpath, type = '    '
      rpath = (relpath fpath).ljust(100)
      if File.exist?(fpath)
        notice "- #{rpath} #{type} OK"
      else
        error("# #{rpath} #{type} KO")
      end
    end

    # On teste l'étape +etape+ (instance FeaTestSheet)
    #
    # TODO: Vérifier le contraire, c'est-à-dire que tous les fichiers
    # qui se trouvent dans les dossiers correspondent bien à des features 
    # existantes/définies.
    def check
      existOrError(steps_folder, 'file')
      USER_TYPES.each do |utype, dtype|
        existOrError(utype_folder = steps_folder(utype), 'file')
        puts "dtype: #{dtype.inspect}"
        dtype[:features].each do |feature|
          fpath = File.join(utype_folder, "can_#{feature[:affixe]}.rb")
          existOrError(fpath, 'FEAT') 
        end

        # Contre-fonctionnalités
        if dtype[:can_not_act_as_next]
          USER_TYPES[dtype[:next_user]][:features].each do |feature|
            fpath = File.join(utype_folder, "CANT_#{feature[:affixe]}.rb")
            existOrError(fpath, 'FEAT') 
          end
        end
      end

    end
  end #/FeaTestSheet
end #/FeaTestModule

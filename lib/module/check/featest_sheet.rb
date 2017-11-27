# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    attr_reader :options

    def existOrError fpath, type = '    ', human_feat
      rpath = (FeaTest.current.relpath fpath).ljust(100)
      if File.exist?(fpath)
        notice "- #{rpath} #{type} OK"
      else
        if options[:build] && type == 'FEAT'
          # TODO
          `mkdir -p "#{File.dirname(fpath)}"`
          File.open(fpath,'wb') do |f| 
          f.write <<~EOT
          say "#{human_feat}"

          # DÉFINIR ICI LE CODE DU TEST
          
          success "#{human_feat}"
          EOT
          end
          "= Fichier #{rpath} construit"
        else
          error("# #{rpath} #{type} KO")
          unless options[:build]
            FeaTest.current.add_aide_required(:fichier_code_test)
          end
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

    def check_utype utype, dtype
      existOrError(utype_folder = steps_folder(utype), 'file')
      dtype[:features].each do |feature|
        check_utype_feature(utype, feature)
      end

      # Check des features propres seulement à l'user-type
      if dtype[:features_only]
        dtype[:features_only].each do |feature|
          check_utype_feature(utype, feature)
        end
      end

      # Contre-fonctionnalités
      if dtype[:features_out]
        dtype[:features_out].each do |feature|
          check_utype_cant_feature(utype, feature)
        end
      end
      if dtype[:can_not_act_as_next]
       per_user_types[dtype[:next_user]][:features].each do |feature|
         check_utype_cant_feature(utype, feature)
        end
      end
    end
    #/check_utype


    def check_utype_feature utype, feat
      if feat[:affixe]
        fpath = File.join(steps_folder(utype),"can_#{feat[:affixe]}.rb")
        existOrError(fpath, 'FEAT', "\#{pseudo} #{feat[:hname]}") 
      else
        error("# La fonctionnalité `#{feat[:hname]}` ne définit pas son affixe (*)")
        FeaTest.current.add_aide_required(:definition_affixe)
      end
    end
    def check_utype_cant_feature utype, feat
      fpath = File.join(steps_folder(utype), "CANT_#{feat[:affixe]}.rb")
      existOrError(fpath, 'FEAT', "\#{pseudo} #{feature_negative feat[:hname]}") 
    end
    def feature_negative hname
      hname.sub(/(peut|voit|trouve)/,'ne \1 pas') 
    end
  end #/FeaTestSheet
end #/FeaTestModule

# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    attr_reader :options
    attr_reader :errors_count

    # On teste l'étape +etape+ (instance FeaTestSheet)
    #
    # TODO: Vérifier le contraire, c'est-à-dire que tous les fichiers
    # qui se trouvent dans les dossiers correspondent bien à des features 
    # existantes/définies.
    def check options = Hash.new

      # Les options de check. Définit par exemple qu'il faut construire
      # ce qui doit l'être.
      @options = options

      # Pour conserver le nombre d'erreurs. Utile surtout pour les
      # tests.
      @errors_count = 0

      feature_file_conform?(steps_folder, 'fold')
      per_user_types.each do |utype,dtype|
        check_utype(utype, dtype)
      end

      return @errors_count
    end
    #/check



    # Méthode qui vérifie la conformité d'un feature-file
    # Pour être conforme, ce feature-file doit :
    # - exister
    # - contenir du test (et pas seulement le code de base)
    #
    # Cette méthode est la méthode générale utilisée par toutes les
    # autres pour vérifier la conformité de la définition d'un code de
    # feature dans un fichier.
    #
    # Cette méthode écrit une ligne de rapport qui contient :
    #  PATH FICHIER      TYPE   EXISTE   CODE
    def feature_file_conform?(fpath, type = '', human_feat)

      file_exists = File.exist?(fpath)
      File.exist?(fpath) ||
        begin
          @errors_count += 1
          if options[:build] && type == 'FEAT'
            build_feature_file(fpath, human_feat)
          else
            unless options[:build]
              FeaTest.current.add_aide_required(:fichier_code_test)
            end
            puts self.class.line_check_report([relative_path(fpath), type, false, nil])
            return
          end
      end

      code_is_ok = type == 'FEAT' ? feature_code_in?(fpath) : nil
      code_is_ok || @errors_count += 1
      if !CLI.option(:'error-only') || false === code_is_ok
        puts self.class.line_check_report([relative_path(fpath), type, true, code_is_ok])
      end
      
    end

    # Retourne true si le fichier +fpath+ contient bien du code
    # de test.
    def feature_code_in? fpath
      code = File.read(fpath).force_encoding('utf-8')
      !!code.gsub(/#(.*)\n/m,"\n").match(/expect/)
    end

    # Construction du feature-file quand il n'existe pas
    def build_feature_file fpath, human_feat
      `mkdir -p "#{File.dirname(fpath)}"`
      File.open(fpath,'wb') do |f| 
        f.write <<~EOT
        say "#{human_feat}"

        # DÉFINIR ICI LE CODE DU TEST

        success "#{human_feat}"
        EOT
      end
      "= Fichier #{rpath} construit"
    end

    # Méthode qui checke que le fichier feature-code soit conforme.
    def check_utype utype, dtype
      feature_file_conform?(steps_folder(utype), 'file')
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
        feature_file_conform?(fpath, 'FEAT', "\#{pseudo} #{feat[:hname]}")
      else
        @errors_count += 1
        error("# La fonctionnalité `#{feat[:hname]}` ne définit pas son affixe (*)")
        FeaTest.current.add_aide_required(:definition_affixe)
      end
    end
    def check_utype_cant_feature utype, feat
      fpath = File.join(steps_folder(utype), "CANT_#{feat[:affixe]}.rb")
      feature_file_conform?(fpath, 'FEAT', "\#{pseudo} #{feature_negative feat[:hname]}")
    end

    def feature_negative hname
      hname.sub(/(peut|voit|trouve)/,'ne \1 pas') 
    end
  end #/FeaTestSheet
end #/FeaTestModule

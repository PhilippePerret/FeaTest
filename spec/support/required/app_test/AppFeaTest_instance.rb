=begin

  AppFeaTest#build([params])

    Construit une nouvelle application-test à partir des données +params+

    +params+
      
      :steps    La liste des étapes. Défaut : [:signin, :home]
      :url_online   URL online. Défaut : 'app-test.alwaysdata.net'
      :url_offline  URL offline. Défaut : 'localhost/tests/appfeat'
      :entete_test_files
          Entête à ajouter à tous les fichiers tests.
          Par défaut : "" (string vide)
      :data_user
          Les données, par type de user, pour pouvoir s'identifier si
          nécessaire. On peut créer les types que l'on veut, en mettant
          en clé le nom (Symbol) du type (p.e. :analyste) et en données le
          hash de données dont on a besoin, avec le password et le mail si
          une inscription est nécessaire.
          Par défaut, on trouve :
        :admin
          Les données administrateur.
          Défaut : {pseudo: 'Admin', password: 'xxxxxxxx', mail: 'admin@app-test.alwasydata.net'}
        :registered
          Les données pour un inscrit.
          Défaut : {pseudo: 'Inscrit', password: 'xxxxxxxx', mail: 'inscrit@app-test.alwaysdata.net'}
        :suscriber
          Les données pour un abonné. L'abonné, à la différence du
          simple inscrit, a payé son inscription.
          Défaut : {pseudo: 'Abonné', password: 'xxxxxxxx', mail: 'suscriber@app-test.alwaysdata.net'}

=end
class AppFeaTest

  # --------------------------------------------------------------------------------
  #
  #    MÉTHODES DE CONSTRUCTION DE L'APPLICATION-TEST
  # 
  # --------------------------------------------------------------------------------
  def build params = Hash.new
    params = default_params(params)

    # Fabrication des dossiers utiles
    `mkdir -p "#{sheets_folder}"`
    params[:steps].each do |step|
      params[:data_user].each do |utype, dtype|
        `mkdir -p "#{steps_folder}/#{step}/#{utype}"`
      end
    end
    build_config_file params
    build_home_ftest_file 
    build_signin_ftest_file
  end

  def default_params params
    params[:steps] ||= [:signin, :home]
    params[:url_online]             ||= 'http://app-test.alwaysdata.net'
    params[:url_offline]            ||= 'localhost/tests/appfeat'
    params[:entete_test_files]      ||= '""'
    # Pour les données utilisateurs
    params[:data_user]              ||= Hash.new
    params[:data_user].key?(:visitor)     || params[:data_user].merge!(visitor: nil)
    params[:data_user].key?(:admin)       || params[:data_user].merge!(admin: default_data_admin)
    params[:data_user].key?(:registered)  || params[:data_user].merge!(registered: default_data_registered)
    params[:data_user].key?(:suscriber)   || params[:data_user].merge!(suscriber: default_data_suscriber)
    return params
  end
  
  # --------------------------------------------------------------------------------
  #
  #    CONSTRUCTION DES FICHIERS REQUIS
  # 
  # --------------------------------------------------------------------------------
  def build_config_file params = Hash.new


    notice "Construction du fichier #{config_file_path}"
    f = File.open(config_file_path,'wb')
    f.write <<-EOC
    module FeaTestModule

      # === REQUIREMENTS ===

      # === LISTE DES ÉTAPES ===
      def steps_sequence
        @steps_sequence ||= [:#{params[:steps].join(', :')}] 
      end

      def url_online  ; '#{params[:url_online]}'  end
      def url_offline ; '#{params[:url_offline]}' end

      def entete_test_files
        #{params[:entete_test_files]}
      end

      # Les données de l'utilisateur, en fonction de son type
      # à écrire en dur dans le début du scénario
      def data_user user_type
        case user_type
        #{params[:data_user].collect do |utype, tdata|
        <<-WHEN
        when #{utype.inspect} # par exemple :admin
          #{tdata.inspect}
        WHEN
        end.join("\n")}
        else
          'nil'
        end
      end #/data_user

    end # /module FeaTestModule
    EOC
    f.close
  end
  def default_data_admin
    {pseudo: 'Admin', mail: 'admin@app-test.alwaysdata.net', password: 'xxxxxxxx'}
  end
  def default_data_registered
    {pseudo: 'Inscrit', mail: 'inscrit@app-test.alwaysdata.net', password: 'xxxxxxxx'}
  end
  def default_data_suscriber
    {pseudo: 'Abonné', mail: 'suscriber@app-test.alwaysdata.net', password: 'xxxxxxxx'}
  end

  def build_home_ftest_file
    p = File.join(sheets_folder, 'home.ftest')
    f = File.open(p,'wb')
    f.write <<-EOF
    STEP: HOME --- Accueil du site
    ==========
      AS: visitor
      -----------
        * trouve une page d'accueil valide  --- home_valide
        * -

      AS: admin --- un administrateur
      ---------
        * +
        * trouve un bouton pour administrer le site --- find_admin_button
    EOF
    f.close
  end
  def build_signin_ftest_file
    p = File.join(sheets_folder, 'signin.ftest')
    f = File.open(p,'wb')
    f.write <<-EOF
    STEP: SIGNIN --- Formulaire d'identification
    ============
      AS: visitor --- un simple visiteur
      -----------
        * Trouve un formulaire conforme   --- find_form_valide

      AS: admin --- un administrateur
      ---------
        * Ne peut plus atteindre le formulaire --- no_form

    EOF
    f.close
  end

  # --------------------------------------------------------------------------------
  #
  #    MÉTHODES FONCTIONNELLES
  # 
  # --------------------------------------------------------------------------------
  def remove
    if File.exist?(APP_TEST_PATH)
      require 'fileutils'
      FileUtils.rm_rf APP_TEST_PATH 
    end
  end

  # --------------------------------------------------------------------------------
  #
  #    CHEMINS D'ACCÈS
  # 
  # --------------------------------------------------------------------------------
  def config_file_path
    @config_file_path ||= File.join(APP_FEATEST_FOLDER,'config.rb')
  end
  def sheets_folder
    @sheets_folder ||= File.join(APP_FEATEST_FOLDER,'sheets') 
  end
  def steps_folder
    @steps_folder ||= File.join(APP_FEATEST_FOLDER,'steps')
  end

end#/AppFeaTest

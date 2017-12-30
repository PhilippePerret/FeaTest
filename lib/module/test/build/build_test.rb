# encoding: utf-8
=begin
   Module de construction du test qui doit être joué
   Note : en fait, il s'agit d'une feuille de test rspec par
   user choisi.
=end
module FeaTestModule

  # Méthode principale de construction des fichier rspec
  # pour les tests.
  def build_test

    # On détruit le dossier qui va contenir les feuilles de tests.
    # Rappel : il y en aura une par type de user choisi
    __dg("* Recréation du dossier des étapes par user",3)
    __db("  steps_by_users_folder : #{steps_by_users_folder}",5)
    FileUtils.rm_rf steps_by_users_folder
    `mkdir -p "#{steps_by_users_folder}"`

    # ---------------------------------------------------------------------
    #
    #   On crée les fichiers pour chaque user, en général seulement celui
    #   défini par l'option --as, qui peut être 'all' pour les prendre tous
    #
    # ---------------------------------------------------------------------
    __dg("*** Boucle sur chaque type d'user",3)
    __dg("    = AS = #{AS.inspect}",5)
    AS.each do |utype|
      puts "  * traitement de l'user de type #{utype.inspect}"
      create_test_file_for_user(utype)
    end

  end


  # Méthode principale de création du fichier par type d'user
  # @param {Symbol} user_type
  #                 Le type de l'user pour lequel il faut faire la
  #                 feuille de test, tel que défini dans la liste
  #                 AS
  #
  def create_test_file_for_user user_type
    __dg("-> create_test_file_for_user(user_type=#{user_type.inspect})",2)
    rspec_file_path = File.join(steps_by_users_folder, "#{user_type}_spec.rb")
    ref = File.open(rspec_file_path,'wb')

    # Écriture du début du fichier test pour un user-type particulier
    code_fichier = <<~RSPEC
    #{preambule_test_file}
    # Pour requérir tout un dossier
    def require_folder p ; Dir["\#{p}/**/*.rb"].each{|m|require m} end
    #{constantes_test_files}

    # On requiert les méthodes communes à tous les tests, par exemple
    # celles pour écrire les messages
    require_folder File.join('#{THISFOLDER}','lib','asset','spec_helpers')
    # On requiert les méthodes du site, qui définissent par exemple des
    # raccourcis pratiques pour cliquer le bouton pour s'identifier, etc.
    require_folder File.join('#{featest_folder}','required')

    # Cette méthode est définie (ou pas) dans le config.rb
    # Elle permet de faire des premières inclusions
    #{respond_to?(:entete_test_files) ? entete_test_files : ''}

    # Pour pouvoir obtenir les données de l'user depuis n'importe où
    def __get_data_user
      FeaTest.current_user_data || begin
        FeaTest.current_user_data = begin
         #{data_user(user_type)}
        end
      end
    end

    # Pour avoir accès à des pseudo constantes partout. Par exemple,
    # le pseudo de l'user courant peut s'obtenir par FTCONSTANTES[:pseudo]
    # même en dehors des tests proprement dits.
    unless defined?(FTCONSTANTES)
      FTCONSTANTES = Hash.new
    end
    FTCONSTANTES.merge!(pseudo: __get_data_user[:pseudo])

    feature 'Feature-Test of web site tested by #{human_user(user_type)}' do
      before(:all) do
        puts DELIMITATION
      end
      # ========== LES LETS =================
      let(:huser) { @huser ||= __get_data_user }
      let(:pseudo) { @pseudo ||= huser ? "\#{huser[:pseudo]} (#{user_type})" : 'inconnu' }
      let(:user) { @user ||= huser.nil? ? User.new() : User.get(huser[:id]) }
      let(:start_time) { @start_time ||= Time.now }
      # =========== /FIN DES LETS ==============

      #{entete_scenario_template(nil, user_type)}

    RSPEC
    # Fin du code du fichier

    ref.write(code_fichier)


    # === LISTE DES ÉTAPES ===
    #
    # Il peut s'agir de toutes les étapes, d'une seule étape ou de plusieurs,
    # dans un ordre aléatoire, suivant les options.
    # L'idée est que `@tested_steps` (pour "étapes testées") ne contienne que les
    # étapes nécessaires, pour simplifier le code (et pouvoir isoler plus
    # facilement les fragments qui échouent)
    #@tested_steps ||= FeaTest.current.steps_sequence
    @tested_steps ||= FeaTest.current.steps

    # On ne prend que les étapes qu'il faut tester
    puts "@tested_steps: #{@tested_steps.inspect}"

    # S'il faut jouer les étapes dans un autre aléatoire
    if CLI.option(:random)
      @tested_steps = @tested_steps.shuffle
    end

    #
    #=== BOUCLE SUR LES ÉTAPES À TESTER ===
    #
    @tested_steps.each do |step|

      # step est l'étape sous forme de symbol (:home, :signin, etc.)
      # Dans la méthode `test_code_for_step_by_user`, elle sera transformée
      # en instance {FeaTest}.
      codetest = test_code_for_step_by_user(step, user_type)

      # Quelque fois, il n'existe pas de test pour le type d'user courant. Avant,
      # on utilisait le type `common` mais c'est inutile maintenant. Donc, dans
      # ce cas, on passe simplement à la suite
      codetest || begin
        __dg("Pas d'étape #{step.inspect} pour le type #{user_type.inspect}. On passe à la suite.")
        next
      end

      ref.write(codetest)
    end

    # BOUT DU FICHIER
    ref.write test_file_footer

    ref.close

  end
  #/ Fin de méthode créant le fichier

  # Entête du block 'scenario'
  # C'est cet entête qui permet de remplacer la balise NEW_SCENARIO pour repartir
  # d'un user "frais"
  #
  # Note : cette méthode sert aussi à featest_sheet.rb
  def entete_scenario_template istep, user_type, pathwriter = ''
    stepstr =
    if istep
      stepref = "#{istep.step.downcase.to_sym.inspect}"
      istep.description && stepref << " (#{istep.description})"
      " - STEP: #{stepref}".gsub(/"/, '\"')
    else
      ''
    end
   <<-EOT
scenario "SCENARIO END#{stepstr} - USER: #{user_type.inspect}" do
    #{pathwriter}
    visit_home_page
    #{user_type != :visitor ? 'signin_user(FeaTest.current_user_data)' : ''}
   EOT
  end

  def step_template
    @step_template ||= <<~RSPEC
    ___FILE_CONTENT___

    RSPEC
  end

  # --------------------------------------------------------------------------------
  #
  #    PORTIONS DU FICHIER TEST GÉNÉRAL POUR UN USER-TYPE
  #
  # --------------------------------------------------------------------------------


  # Pour créer le rescue de tous les features-case.
  #
  # Note : il est utilisé dans featest_sheet.rb, mais comme il n'y a
  # que le nom de l'étape qui change, on le construit une bonne fois pour
  # toutes puis on le templatize.
  def build_rescue_de_fin_de_feature istep
    template_fin_rescue ||=
      begin
        t = Array.new
        t << "rescue Exception => e"
        if CLI.option(:'fail-fast')
          t << "  raise e"
        else
          t << "  failure(\"Failure dans l’étape :%s : \#{e.message}\")"
          if CLI.option(:debug)
            t << "  failure(e.backtrace.join(\"\\n\"))"
          end
        end
        t << "end"
        "#{t.join("\n    ")}"
      end
    template_fin_rescue % [istep.step.downcase]
  end

  # Retourne les codes des tests pour l'étape +step+ pour l'user de type +utype+ni
  #
  # Note : c'est cette méthode qui retourne le code qui sera écrit dans le fichier
  # total pour l'utilisateur.
  #
  # C'est dans cette méthode qu'on déterminer tous les bouts de feature-code qui
  # devront être assemblés pour construire un test pour user de type +utype+ et
  # l'étape +step+ (FeaTestSheet).
  #
  def test_code_for_step_by_user step, utype
    __dg("-> test_code_for_step_by_user(step=#{step.inspect}, utype=#{utype.inspect})",2)
    istep = FeaTestSheet.sheets_steps[step]
    code  = FeaTestSheet.sheets_steps[step].full_test_code_for(utype)
    code || (return '')
    code = traite_inclusions_in(code)
    code = traite_comments_in(code)
    return code
  end

  def preambule_test_file
    @preambule_test_file ||= <<~EOT
    =begin

        CE FICHIER NE DOIT PAS ÊTRE TOUCHÉ, IL EST CONSTRUIT DE FAÇON
        PROGRAMMATIQUE PAR UN SCRIPT (TEST_BY_STEP/build_and_run.rb)

    =end

    class FeaTest
      class << self
        attr_accessor :current_user_data
      end
    end
    EOT
  end

  def constantes_test_files
    @constantes_test_files ||= <<~EOT
    # Pour ne pas le définir pour chaque test
    if !defined?(DELIMITATION)
      BASE_URL          = 'http://#{online? ? url_online : url_offline}'
      DELIMITATION      = "*\\n*\\n\#{'*'*80}\\n*\\n*"
      ONLINE            = #{(!!CLI.option(:online)).inspect}
      OFFLINE           = !ONLINE
      WAIT_COEFFICIANT  = #{CLI.option(:wait)}
      DONT_SAY_ANYTHING = #{(CLI.option(:silent)||CLI.option(:quiet)) ? 'true' : 'false'}
      DEBUG_LEVEL       = #{CLI.option(:'debug-level')}
      EXHAUSTIF         = #{(!!CLI.option(:exhaustif)).inspect}
      DISPLAY_PATHS     = #{CLI.option(:path).inspect}
    end
    EOT
  end

  def test_file_footer
    @test_file_footer ||= build_test_file_footer
  end
  def build_test_file_footer
    t = Array.new
    if !CLI.option(:'fail-fast')
      t << "    if process_error_count > 0"
      mess = "\#{process_error_count} erreurs sont survenus au cours du test."
      CLI.option(:debug) || mess << " Vous pouvez jouter l'option `--debug` pour afficher les erreurs."
      t << "      raise \"#{mess}\""
      t << "    end"
    end
    t << "    puts DELIMITATION"
    t << "    wait(5)"
    t << "  end # Fin de scénario"
    t << "end # Fin de feature"
    return t.join("\n")
  end

  # Traite les inclusions dans le code +code+ et retourne le nouveau code
  def traite_inclusions_in code
    # On regarde si le fichier a des textes inclus
    if code.match(/^[ \t]*<-/)
      code.gsub!(/^[ \t]*<-([a-zA-Z0-9_\/\.]+)$/){
        finc = search_for_included_file("_#{$1}", fpath)
        "#{traite_inclusions_in(finc)}"
      }
    end
    return code
  end

  def traite_comments_in code
    code
      .gsub(/=begin(.*?)=end/m,'')
      .gsub(/# (.*?)\n/,"\n")
      .gsub(/#[ \t]?\n/,"\n")
      .gsub(/\n\n\n+/,"\n\n")
  end

  def search_for_included_file fname, fpath
    File.exist?(fname) && (return fname)
    faff = File.join(File.dirname(fpath),fname)
    finc = faff
    File.exist?(finc) && (return finc)
    finc = "#{faff}_tbs.rb"
    File.exist?(finc) && (return finc)
    finc = "#{faff}.rb"
    File.exist?(finc) && (return finc)
    fatale_error "Impossible de trouver le fichier inclus avec `#{fname}`"
  end

end #/module FeaTestModule

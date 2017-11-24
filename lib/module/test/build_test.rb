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
    ref.write(<<~RSPEC)
    #{preambule_test_file}
    # === REQUIREMENTS ===
    #{entete_test_files || ''}

    #{exhaustive_method}

    #{constantes_test_files}

    feature 'Visite du site testée (par #{human_user(user_type)})', visite: true do

      def retour_accueil
        say "\#{@pseudo} revient à l’accueil en cliquant sur le lien “Accueil” sous le logo"
        within('section#header'){click_link 'accueil'}
      end
      def wait time
        WAIT_COEFFICIANT || return
        sleep WAIT_COEFFICIANT * time
      end

      before(:all) do

        @url = site.configuration.send("url_\#{ENV['TEST_ONLINE'] == 'true' ? 'online' : 'offline'}".to_sym)
        @url = "http://\#{@url}"

        @from_step = ENV['RSPEC_FROM_STEP'].nil_if_empty ? ENV['RSPEC_FROM_STEP'].to_sym : :start
        @to_step   = ENV['RSPEC_TO_STEP'].nil_if_empty   ? ENV['RSPEC_TO_STEP'].to_sym : :end

        puts "= @url = \#{@url}, @from_step = \#{@from_step.inspect}, @to_step = \#{@to_step.inspect}"

      end

    scenario '=> #{human_user(user_type).titleize} peut visiter les parties testées du site' do

      start_time = Time.now.to_i

      puts DELIMITATION

      #{data_user(user_type)} #-- Définition de huser --#

      process_error_count = 0

      # Pour simplifier l'écriture
      pseudo  = huser ? huser[:pseudo] : 'inconnu'
      @pseudo = pseudo
      user =
        if huser.nil?
          User.new
        else
          User.get(huser[:id])
        end

      # Tous les visiteurs, quels qu'ils soient, commencent par se rendre
      # sur la page d'accueil
      # (sauf qu'il faudra aussi tester des arrivées directes sur certaines
      #  pages, comme ça arrive depuis un mail)
      visit "\#{@url}"
      notice "\#{pseudo} arrive sur le site"

      # Tous les visiteurs, sauf les simples visiteurs, doivent s'identifier
      # en arrivant sur le site (pour visiter réellement les parties avec leur
      # statut)
      #{user_type != :visitor ? real_code_for_section(:signin, user_type) : ''}

      # Si on doit commencer les tests depuis le début
      if @from_step == :start
        notice "*** Démarrage du test à partir du début ***"
        @test_running = true
      end

    RSPEC


    # === LISTE DES ÉTAPES ===
    #
    # Il peut s'agir de toutes les étapes, d'une seule étape ou de plusieurs,
    # dans un ordre aléatoire, suivant les options.
    # L'idée est que `@tested_steps` (pour "étapes testées") ne contienne que les
    # étapes nécessaires, pour simplifier le code (et pouvoir isoler plus
    # facilement les fragments qui échouent)
    @tested_steps ||= FeaTest.current.steps_sequence

    # S'il faut jouer les étapes dans un autre aléatoire
    if CLI.option(:random)
      @tested_steps = @tested_steps.shuffle
    end

    #
    #
    #=== BOUCLE SUR LES ÉTAPES À TESTER ===
    #
    #
    @tested_steps.each do |section|
      codetest = real_code_for_section(section, user_type)
      ref.write(
        section_template
        .gsub(/__SECTION__/, section.to_s)
        .sub(/___FILE_CONTENT___/, codetest)
      )
    end

    # BOUT DU FICHIER

    ref.close

  end
  #/ Fin de méthode créant le fichier
  def section_template
    @section_template ||= <<~RSPEC
    if @from_step == :__SECTION__
      notice "*** Démarrage du test à partir de __SECTION__ ***"
      @test_running = true
    end

    if @test_running
      begin

      ___FILE_CONTENT___

      rescue Exception => e
        if !#{CLI.option(:'fail-fast').inspect}
          failure("Failure dans l'étape :__SECTION__ : \#{e.message}")
          if #{CLI.option(:debug).inspect}
            failure(e.backtrace.join("\\n"))
          end
          process_error_count += 1
        else
          raise e
        end
      end

    end #/test_running

    if @to_step == :__SECTION__
      notice "=== Arrêt des tests à l'étape __SECTION__ ==="
      @test_running = false
    end

    RSPEC
  end

  # --------------------------------------------------------------------------------
  #
  #    PORTIONS DU FICHIER TEST GÉNÉRAL POUR UN USER-TYPE
  # 
  # --------------------------------------------------------------------------------


  def preambule_test_file
    @preambule_test_file ||= <<~EOT
    =begin
    
        CE FICHIER NE DOIT PAS ÊTRE TOUCHÉ, IL EST CONSTRUIT DE FAÇON
        PROGRAMMATIQUE PAR UN SCRIPT (TEST_BY_STEP/build_and_run.rb)
    
    =end

    EOT
  end

  def exhaustive_method
    @exhaustive_method ||= <<~EOT
    class Array
      def exhaust default = 3
        #{CLI.option(:exhaustif) ? 'self' : 'self.shuffle[0..(default - 1)]'}
      end
    end #/Array
    EOT
  end

  def constantes_test_files
   @constantes_test_files ||= <<~EOT
   # Pour ne pas le définir pour chaque test
   if !defined?(DELIMITATION)
     DELIMITATION      = "*\\n*\\n\#{'*'80}\\n*\\n*"
     ONLINE            = #{(!!CLI.option(:online)).inspect}
     OFFLINE           = !ONLINE
     WAIT_COEFFICIANT  = #{CLI.option(:wait)}
     DONT_SAY_ANYTHING = #{(CLI.option(:silent)||CLI.option(:quiet)) ? 'true' : 'false'}
     DEBUG_LEVEL       = #{CLI.option(:'debug-level')}
     EXHAUSTIF         = #{(!!CLI.option(:exhaustif)).inspect}
   end
   EOT
  end
  def test_file_footer
    @test_file_footer ||= <<~RSPEC

        if !#{CLI.option(:'fail-fast').inspect} && process_error_count > 0
          add =
            if #{CLI.option(:debug).inspect} != true
              ''
            else
              " Vous pouvez ajouter l'option `--debug` pour afficher les messages complets d'erreur."
            end
          raise "\#{process_error_count} erreurs sont survenues au cours du test.\#{add}"
        end

        puts DELIMITATION
        wait(5)
      end
    end

    RSPEC

  end

  # Retourne le path au fichier +section+ à utiliser en fonction du statut
  # de l'user visitant le site.
  #
  def real_file_for_section section, utype
    base_section_path = File.join(steps_folder,section.to_s)
    # On va déterminer le fichier contenant le code de cette étape en fonction :
    #  * du fait qu'un dossier existe ou que c'est un simple fichier
    #  * du type de visiteur
    #  * du fait qu'un fichier existe ou non pour ce visiteur là.
    if File.directory? base_section_path
      if File.exist?(File.join(base_section_path,"#{utype}.rb"))
        File.join(base_section_path,"#{utype}.rb")
      elsif File.exist?(File.join(base_section_path,"#{utype}_tbs.rb"))
        File.join(base_section_path,"#{utype}_tbs.rb")
      elsif File.exist?(File.join(base_section_path,'common_tbs.rb'))
        File.join(base_section_path,'common_tbs.rb')
      else
        File.join(base_section_path,'common.rb')
      end
    else
      "#{base_section_path}.rb"
    end
  end

  # Traite les inclusions dans le code +code+ et retourne le nouveau code
  def traite_inclusions_in fpath
    __dg("-> traite_inclusions_in(#{fpath.inspect})",3)
    File.exist?(fpath) || (return "# [MISSING FILE: #{fpath}]")
    code = File.read(fpath)
    # On regarde si le fichier a des textes inclus
    if code.match(/^[ \t]*<-/)
      code.gsub!(/^[ \t]*<-([a-zA-Z0-9_\/\.]+)$/){
        finc = search_for_included_file("_#{$1}", fpath)
        "#{traite_inclusions_in(finc)}"
      }
    end
    return "message_inclusion('#{fpath}')\n#{code}"
  end

  def traite_comments_in code
    code
      .gsub(/=begin(.*?)=end/m,'')
      .gsub(/# (.*?)\n/,"\n")
      .gsub(/#\n/,"\n")
      .gsub(/\n\n\n+/,"\n\n")
  end


  # Retourne le code épuré pour la section +section+ de l'utilisateur défini
  def real_code_for_section section, utype
    fpath = real_file_for_section(section, utype)
    codetest = traite_inclusions_in( fpath )
    # On supprime tous les commentaires et blancs inutiles
    codetest = traite_comments_in(codetest)
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

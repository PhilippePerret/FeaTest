# ÉTAPES DE TESTS (pour --from et --to)
# Elles sont définies dans les fichiers FEATEST où chaque étape définit
# ses propres fonctionnalités.
# Donc cette données devra être remplacée par la lecture des fichiers
# de featest.
ETAPES = [
  # :signin, # toujours ajoutée si statut ≠ :visitor
  :home,
  :profils,
  :outils,
  :signup,
  :blog,
  :aide,
  :narration,
  :updates,
  :contact
]

# Pour l'option `--as` (qui peut avoir aussi la valeur 'all')
USER_TYPES = {
  admin:        'l’administratrice',
  visitor:      'le simple visiteur',
  inscrit:      'le simple inscrit',
  suscriber:    'l’abonné',
  auteur_unan:  'l’auteur du programme UN AN UN SCRIPT',
  analyste:     'l’analyste'
}

=begin

  Taper `$> test_scenariopole --help` pour obtenir de l'aide

=end

require './spec/spec_helper'
require_lib_site

# Une erreur susceptible d'interrompre la visite testée
def fatale_error msg
  raise "\n#\n#\n# ERREUR : #{msg}\n#\n#\n#"
end

THISFOLDER = File.dirname(File.expand_path(__FILE__))

# Les arguments de la commmande. Pourra définir:
# ARGS = {
#   :online     Si true, on joue les tests online
#   :from       depuis cette ETAPE
#   :to         jusqu'à cette ETAPE
#   :as         en tant que :admin, :visitor, :inscrit, :auteur_unan, :analyste
#   :grade      Le grade de l'utilisateur
# }
ARGS = Hash.new

ARGV.each do |paire|
  if paire.start_with?('--')
    var, val = paire[2..-1].split('=')
  elsif paire.start_with?('-')
    var, val = paire[1..-1].split('=')
  else
    next
  end
  ARGS.merge!(var.to_sym => val || true)
end

# Valeurs rectifiées
# ===================

# Le ou les types de user à traiter
ARGS[:as] =
if ARGS[:as].nil?
  [:visitor]
elsif ARGS[:as].match(/,/)
  ARGS[:as].split(',').collect{|utype| utype.strip.to_sym}
elsif ARGS[:as] == 'all'
  USER_TYPES.keys
else
  [ARGS[:as].to_sym]
end

ARGS[:'debug-level'] || ARGS.merge!(:'debug-level' => 0)

ARGS[:'non-exhaustif'] && ARGS[:exhaustif] = false

# === AIDE DEMANDÉE ===
if ARGS[:help]
  code_help = File.read(File.join(THISFOLDER,'help.txt'))
  code_help.sub!(/__ETAPES__/, ':' + ETAPES.join("\n      :"))
  code_help.sub!(/__USERS__/, USER_TYPES.keys.join("\n                "))
  puts code_help
  exit 0
end


# Ajustement en fonction des options
if ARGS[:step]
  ARGS[:step] = ARGS[:step].to_sym
  ETAPES.include?(ARGS[:step]) || fatale_error("L'étape `#{ARGS[:step].inspect}` est inconnue.")
  ARGS[:from] = ARGS[:step]
  ARGS[:to]   = ARGS[:step]
  # On vérifie que l'étape existe
elsif ARGS[:steps]
  ARGS[:steps] = ARGS[:steps].split(',').collect{|e| e.to_sym}
  # On vérifie que les étapes existent
  ARGS[:steps].each do |step|
    ETAPES.include?(step) || fatale_error("L'étape `#{step.inspect}` est inconnue.")
  end
end

ARGS[:from] && ARGS[:from] = ARGS[:from].to_sym
ARGS[:to]   && ARGS[:to]   = ARGS[:to].to_sym

if ARGS[:fast]
  ARGS[:wait]   = 0
  ARGS[:silent] = true
end

if ARGS[:wait].nil?
  WAIT_COEFFICIANT = 1
else
  WAIT_COEFFICIANT = ARGS[:wait].to_i
end

FAIL_FAST =
  if ARGS.key?(:'fail-fast')
    '--fail-fast'
  else
    '--no-fail-fast'
  end


# Le visiteur qui visite, en version humaine, pour les textes
def human_user utype
  USER_TYPES[utype] || 'le visiteur quelconque'
end

# Les données de l'utilisateur, à écrire en dur dans le début du scénario
def data_user utype
  case utype
  when :admin
    'huser = {
      id: 3, pseudo: "Marion", mail: data_marion[:mail],
      password: data_marion[:password],
      created_at: marion.data[:created_at]
      }'
  when :analyste
    <<-HTML
    huser = get_data_random_user(admin: false, analyste: true, grade: #{ARGS[:grade] || 'nil'})
    HTML
  when :suscriber
    <<-HTML
    huser = get_data_random_user(
              admin: false, analyste: false, suscribed: true,
              grade: #{ARGS[:grade] || 'nil'}
              )
    HTML
  when :inscrit
    <<-HTML
    huser = get_data_random_user(admin: false, analyste: false, grade: #{ARGS[:grade] || 'nil'})
    HTML
  when :auteur_unan
    <<-HTML
    require_support_unanunscript
    huser = unanunscript_create_auteur(grade: #{ARGS[:grade] || 'nil'})
    HTML
  else
    'huser = nil'
  end
end

# ---------------------------------------------------------------------
#
#   CONSTRUCTION DU FICHIER TEST COMPLET
#
# ---------------------------------------------------------------------
TEST_BY_STEP_FOLDER = File.expand_path(File.dirname(__FILE__))

# Si on doit procéder au test pour plusieurs user (tous seulement, pour le
# moment, on met toutes les feuilles de test dans ce dossier)
RSPEC_FOLDER_PATH = File.join(TEST_BY_STEP_FOLDER,'steps_by_user')
FileUtils.rm_rf RSPEC_FOLDER_PATH
`mkdir -p "#{RSPEC_FOLDER_PATH}"`



# Retourne le path au fichier +section+ à utiliser en fonction du statut
# de l'user visitant le site.
#
def real_file_for_section section, utype
  base_section_path = File.join(TEST_BY_STEP_FOLDER,'_STEPS_FOLDER', "#{section}")

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


# ---------------------------------------------------------------------
#
#   On crée les fichiers pour chaque user, en général seulement celui
#   défini par l'option --as, qui peut être 'all' pour les prendre tous
#
# ---------------------------------------------------------------------
ARGS[:as].each do |user_type|

  rspec_file_path = File.join(RSPEC_FOLDER_PATH, "#{user_type}_spec.rb")

  ref = File.open(rspec_file_path,'wb')

  ref.write(<<-RSPEC)
=begin

  CE FICHIER NE DOIT PAS ÊTRE TOUCHÉ, IL EST CONSTRUIT DE FAÇON
  PROGRAMMATIQUE PAR UN SCRIPT (TEST_BY_STEP/build_and_run.rb)

=end

# === REQUIREMENTS ===
require_lib_site
require_support_db_for_test
require_support_integration
require_folder './lib/required_when_admin'

class Array
  # Suivant le mode EXHAUSTIF, retourne toute la liste
  # ou seulement +nombre_defaut+ éléments choisis au hasard,
  # 3 par défaut
  # Ajouter l'options `--exhaustif` à la commande test_spole
  # pour traiter tous les éléments
  def exhaust default = 3
    #{
      ARGS[:exhaustif] ? 'self' : 'self.shuffle[0..(default - 1)]'
     }
  end
end #/Array

# Pour ne pas le définir pour chaque test
if !defined?(DELIMITATION)
  DELIMITATION      = "*\\n*\\n#{'*'*80}\\n*\\n*"
  ONLINE            = #{(!!ARGS[:online]).inspect}
  OFFLINE           = !ONLINE
  WAIT_COEFFICIANT  = #{WAIT_COEFFICIANT}
  DONT_SAY_ANYTHING = #{(ARGS[:silent] || ARGS[:quiet]) ? 'true' : 'false'}
  DEBUG_LEVEL       = #{ARGS[:'debug-level']}
  EXHAUSTIF         = #{(!!ARGS[:exhaustif]).inspect}
end

feature 'Visite du site Scénariopole testée (par #{human_user(user_type)})', visite: true do

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


template = <<-RSPEC
if @from_step == :__SECTION__
  notice "*** Démarrage du test à partir de __SECTION__ ***"
  @test_running = true
end

if @test_running
  begin

  ___FILE_CONTENT___

  rescue Exception => e
    if '#{FAIL_FAST}' == '--no-fail-fast'
      failure("Failure dans l'étape :__SECTION__ : \#{e.message}")
      if #{ARGS[:debug].inspect}
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

  # === LISTE DES ÉTAPES ===
  #
  # Il peut s'agir de toutes les étapes, d'une seule étape ou de plusieurs,
  # dans un ordre aléatoire, suivant les options.
  # L'idée est que `@tested_steps` (pour "étapes testées") ne contienne que les
  # étapes nécessaires, pour simplifier le code (et pouvoir isoler plus
  # facilement les fragments qui échouent)
  @tested_steps ||= begin
    case
    when ARGS[:steps] then ARGS[:steps]
    when ARGS[:from] || ARGS[:to]
      get_it = false || !ARGS.key?(:from)
      arr = Array.new
      ETAPES.each do |step|
        step == ARGS[:from] && get_it = true
        get_it && arr << step
        step == ARGS[:to] &&  break
      end
      arr
    else ETAPES
    end
  end

  # S'il faut jouer les étapes dans un autre aléatoire
  if ARGS[:random]
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
      template
        .gsub(/__SECTION__/, section.to_s)
        .sub(/___FILE_CONTENT___/, codetest)
    )
  end




  # BOUT DU FICHIER
  ref.write(<<-RSPEC)

    if '#{FAIL_FAST}' == '--no-fail-fast' && process_error_count > 0
      add =
        if #{ARGS[:debug].inspect} != true
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


  ref.close

end
#/ Fin de boucle sur tous les users voulus


#   /Fin de la construction des feuilles de test pour chaque user
#    ou seulement celui qu'on veut voir.
#
# ---------------------------------------------------------------------

online = ARGS[:online]



cmd = "cd \"#{File.expand_path('.')}\";TEST_ONLINE=#{ARGS[:online].inspect} RSPEC_FROM_STEP=#{ARGS[:from]} RSPEC_TO_STEP=#{ARGS[:to]} "
cmd << "rspec #{RSPEC_FOLDER_PATH} #{FAIL_FAST} -fd;"
# Ici, noter que ce fail-fast ---------^
# ne servira à rien. Lire dans
# l'aide pourquoi, en consultant
# l'option --fail-fast (lancer l'aide par `test_spole --help`)
#
# Noter aussi que maintenant c'est toujours un dossier qui contient les feuilles
# de test, pour pouvoir traiter plusieurs types d'user en même temps

puts <<-TXT

========== TEST LANCÉ EN #{online ? 'ONLINE' : 'OFFLINE'} ============
= Ce test est construit à partir des bouts de code se trouvant dans
= le dossier TEST_BY_STEP/_STEPS_FOLDER
=
= Test effectué à  : #{Time.now}
= Users types      : #{ARGS[:as].pretty_join}
= Depuis l'étape   : #{ARGS[:from] ? ARGS[:from].inspect : '(départ)'}
= Jusqu'à l'étape  : #{ARGS[:to] ? ARGS[:to].inspect : '(fin)'}
= Ordre            : #{ARGS[:random] ? 'aléatoire' : 'normal'}
= Ordre des étapes : #{@tested_steps.pretty_join}
= Coefficiant wait : #{WAIT_COEFFICIANT}#{WAIT_COEFFICIANT == 0 ? ' (fast)' : ''}
=

TXT

# Pour jouer la feuille de test en inscrivant le détail de la sortie en
# console.
require 'pty'
raw = ''
PTY.spawn(cmd) do |stdout_err, stdin, pid|
  begin
    while (char = stdout_err.getc)
      raw << char
      print char
    end
  rescue Errno::EIO # always raised when PTY runs out of input
  ensure
    Process.waitpid pid # Wait for PTY to complete before continuing
  end
end

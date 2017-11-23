# encoding: utf-8
module FeaTestModule

  def run_test

    cmd = "cd \"#{app_folder}\";TEST_ONLINE=#{online?.inspect}"
    cmd << " rspec #{steps_by_users_folder}#{CLI.option(:'fail-fast') ? '--fail-fast' : ''} -fd;"
    # Ici, noter que ce fail-fast ---------^
    # ne servira à rien. Lire dans
    # l'aide pourquoi, en consultant
    # l'option --fail-fast (lancer l'aide par `test_spole --help`)
    #
    # Noter aussi que maintenant c'est toujours un dossier qui contient les feuilles
    # de test, pour pouvoir traiter plusieurs types d'user en même temps

    puts entete_feedback



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

  end

  def entete_feedback
    
    <<~TXT

    ========== TEST LANCÉ EN #{online? ? 'ONLINE' : 'OFFLINE'} ============
    = Ce test est construit à partir des bouts de code se trouvant dans
    = le dossier TEST_BY_STEP/_STEPS_FOLDER
    =
    = Test effectué à  : #{Time.now}
    = Users types      : #{FeaTestSheet::AS.pretty_join}
    = Ordre            : #{CLI.option(:random) ? 'aléatoire' : 'normal'}
    = Ordre des étapes : #{@tested_steps.pretty_join}
    = Coefficiant wait : #{CLI.option(:wait)}#{CLI.option(:wait) == 0 ? ' (fast)' : ''}
    =
    TXT
  end
end #/FeaTestModule

# encoding: utf-8

# Méthode pour le débuggage de l'application
# Utiliser l'option --debug-level pour définir le niveau
#
# De façon générale :
#
# L'entrée dans les méthodes se met au niveau 2
# Les valeurs des variables se mettent au niveau 5
def __dg msg, dbg_level = 0
  @debug_level ||= CLI.option(:'debug-level')
  @debug_level > dbg_level || return
  puts "--- #{msg}"
end
alias :__db :__dg

def error msg
  msg, backtrace =
  case msg
  when String
    [msg, nil]
  else
    [msg.message, msg.backtrace.join("\n")]
  end
  puts "\033[41m#{msg}\033[0m"
  CLI.option(:debug) && backtrace && puts(backtrace)
  return false
end


# Une erreur susceptible d'interrompre la visite testée
def fatale_error msg
  error "\n#\n#\n# ERREUR : #{msg}\n#\n#\n#"
  exit 1
end

def notice msg
  puts "\033[44m#{msg}\033[0m"
end

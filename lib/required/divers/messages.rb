# encoding: utf-8



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

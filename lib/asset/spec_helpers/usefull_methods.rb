# encoding: utf-8

class Array
  def exhaust default = 3
    CLI.option(:exhaustif) ? self : self.shuffle[0..(default - 1)]
  end
end #/Array

def say msg
  DONT_SAY_ANYTHING && return
  page.execute_script("__notice(\"#{msg}\");")
  sleep WAIT_COEFFICIANT * ((msg.length.to_f / 13) - 0.5) # Laisser le temps de lire le texte
  # On supprime le message pour qu'il ne gêne pas la navigation
  page.execute_script('Flash.clearAll()')
  sleep (WAIT_COEFFICIANT * 0.5)
end

def wait time
  WAIT_COEFFICIANT || return
  sleep WAIT_COEFFICIANT * time
end

# Pour marquer le path du fichier inclus
def __write_path p
  message_inclusion p
end

def message_inclusion fpath
  DISPLAY_PATHS || return
  @appfolder ||= File.expand_path('.')
  relpath = fpath.sub(/#{@appfolder}\/spec\/features\//,'')
  # puts "\e[33m[<- #{relpath}]\e[0m"
  # puts "\x1b[93;41 m[<- #{relpath}]\x1b[0m"
  reste = 120 - relpath.length
  puts "\033[90;2m#{' '*reste}vim #{relpath}\033[0m"
  #             ^-------------- 2 sera très clair, presque invisible, 3 moins clair
end

# Pour écrire un message neutre en console
def notice message
  verbose? || return
  puts "\033[33m#{success_tab}#{message}\033[0m"
  sleep 0.1
end

# Pour écrire un message de succès en console
def success message
  verbose? || return
  puts "\e[32m#{success_tab}#{message}\e[0m"
  sleep 0.1
end


def failure message
  add_error_count
  puts "Dans failure, verbose? est #{verbose?.inspect}"
  verbose? || return
  puts "\e[31m#{success_tab}#{message}\e[0m"
  sleep 0.1
end

# Pour rouvrir une nouvelle page avec un nouvel user ou le même
# mais non connecté
def visit_home_page with_message = true
  visit BASE_URL
  with_message && notice("#{FTCONSTANTES[:pseudo]} arrive sur le site")
end

# Pour comptabiliser le nombre d'erreur
def add_error_count
  @process_error_count ||= 0
  @process_error_count += 1
end

def reset_error_count
  @process_error_count = 0
end

def process_error_count ; @process_error_count || 0 end

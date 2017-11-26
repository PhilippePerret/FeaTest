# encoding: utf-8

# @param {Hash} params
#               :default    Valeur par défaut à mettre dans le fichier
def askForText params
  if yesOrNo("Êtes-vous prêt ?")
    fp = './.te.txt'
    File.unlink(fp) if File.exist?(fp)
    File.open(fp,'wb'){|f| f.write "#{params[:default]}\n"}
    `mate "#{File.expand_path(fp)}"`
    if yesOrNo "Puis-je prendre le contenu du fichier ?"
      begin
        yesOrNo("Le fichier est-il bien enregistré et fermé ?") || raise
      rescue
        retry
      end
      contenu = File.read(fp).force_encoding('utf-8')
      File.exist?(fp) && File.unlink(fp)
      return contenu
    end#/Si ruby peut prendre le code de la signature
  end#/En attendant que l'utilisateur soit prêt
  return nil
end


# Pose la +question+ est retourne TRUE si la réponse est oui (dans tous les
# formats possible) ou FALSE dans le cas contraire.
def yesOrNo question
  puts "#{question} (y/n)"
  r = STDIN.gets.strip
  case r.upcase
  when 'N','NO','NON' then return false
  else return true
  end
end

# Pose la +question+ qui attend forcément une valeur non nulle et raise
# l'exception +msg_error+ dans le cas contraire.
def askForOrRaise(question, msg_error = "Cette donnée est obligatoire")
  puts question
  r = STDIN.gets.strip
  r != '' || raise(msg_error)
  return r
end

# Pose la +question+ et retourne la réponse, même vide.
def askFor(question, default = nil)
  default && question << " (défaut : #{default})"
  puts question
  retour = STDIN.gets.strip
  retour != '' ? retour : default
end

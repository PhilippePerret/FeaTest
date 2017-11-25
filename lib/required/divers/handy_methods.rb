# encoding: utf-8

def require_folder fpath
  Dir["#{fpath}/**/*.rb"].each{|m|require m}
end

def require_module mname
  require_folder File.join(THISFOLDER,'lib','module',mname)
end

def relative_path path
  path.sub(/^#{FeaTest.current.main_folder}/,'.')
end
# Retourne true si le path +path+ existe (fichier ou dossier), ou
# retourne false en écrivant un message d'erreur.
def existOrError path
  File.exist?(path) || error("File `#{relative_path path}` introuvable.")
end

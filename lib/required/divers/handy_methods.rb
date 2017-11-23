# encoding: utf-8

def require_folder fpath
  Dir["#{fpath}/**/*.rb"].each{|m|require m}
end

def require_module mname
  require_folder File.join(THISFOLDER,'lib','module',mname)
end

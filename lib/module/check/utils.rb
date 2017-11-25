# encoding: utf-8
module FeaTestModule

  def relpath fpath
    fpath.sub(/^#{main_folder}/,'.')
  end
  
  def existOrError fpath, type = '    '
    rpath = (relpath fpath).ljust(100)
    if File.exist?(fpath)
      notice "- #{rpath} #{type} OK"
      return true
    else
      error("# #{rpath} #{type} KO")
    end
  end

end #/FeaTestModule

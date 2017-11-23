# encoding: utf-8
class File
  class << self

    def existsOrRaise fpath, err_msg
      File.exist?(fpath) || raise(err_msg % fpath)
    rescue Exception => e
      error e.message
      exit 1
    end

  end #/<< self
end #/File

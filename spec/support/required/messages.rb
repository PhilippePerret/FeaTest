class FTMessage
  class << self
    attr_accessor :messages
    def reset_messages
      #puts "-> reset_messages", true
      @messages = Array.new
      #puts "<- reset messages", true
    end
    def show_messages options = Hash.new
      #puts "-> show_messages", true
      if @messages.is_a?(Array)
        puts @messages.join("\n"), true
      else
        puts "Aucun message à afficher", true
      end
      options[:reset] && @messages = Array.new
      #puts "<- show_messages", true
    end
  end #/<< self
end #/FTMessage

alias :real_puts :puts
def puts msg, forcer = false
  if forcer
    real_puts msg
  else
    FTMessage.messages ||= Array.new
    FTMessage.messages << msg
  end
end

# encoding: utf-8
module FeaTestModule
  class Help
    class << self

      def display
        if CLI.option(:aide)
          `open -a MarkdownLife "#{manuel_path}"`
        elsif CLI.option(:tuto)
          `open -a MarkdownLife "#{tuto_path}"`
        elsif CLI.option(:man)
          Dir.chdir(THISFOLDER) do
            exec "man ./man"
          end
        else
          puts <<~EOC

          === AIDES DE FEATEST ===

              featest help --aide/-a  # => L'aide
              featest help --tuto/-t  # => Le tutoriel
              featest help --man/-m   # => le manpage


          EOC
        end
      end

      def manuel_path
        @manuel_path ||= File.join(THISFOLDER,'lib','asset','help.md')
      end
      def tuto_path
        @tuto_path ||= File.join(THISFOLDER,'lib','asset','tuto.md')
      end
    end #/<< self
  end#/Help
end #/FeaTestModule

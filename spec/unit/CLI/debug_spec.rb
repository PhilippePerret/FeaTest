=begin

  Test des valeurs pour CLI au niveau du débuggage en fonction
  des options de commande.

  Note : me permet aussi de voir comment gérer le test de ce genre de
  chose qui dépend aussi de la ligne de commande, et donc : comment le
  contrôler depuis les tests (sans mettre la variable dans l'environ-
  nement).

=end
describe 'CLI' do
  describe 'CLI::debug_level' do
    it 'répond' do
      expect(CLI).to respond_to :debug_level
    end
    context 'sans niveau de débug défini en ligne de commande' do
      it 'retourne la valeur 0' do
        ARGV.replace ['check']
        CLI.parse
        expect(CLI.debug_level).to eq(0)
      end
    end
    context 'avec seulement l’option de débug en ligne de commande' do
      it 'retourne la valeur 5' do
        ARGV.replace ['check', '-dg']
        CLI.parse
        expect(CLI.debug_level).to eq(5)
      end
    end
    
    context 'avec un niveau de débuggage explicite en ligne de commande' do
      it 'retourne la valeur spécifiée' do
        ARGV.replace ['check', '--debug-level=8']
        CLI.parse
        expect(CLI.debug_level).to eq(8)
        ARGV.replace ['check', '--debug-level=3']
        CLI.parse
        expect(CLI.debug_level).to eq(3)
      end
      
    end
  end
end


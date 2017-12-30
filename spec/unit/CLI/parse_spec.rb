=begin

  Test de la méthode principale qui parse la ligne de commande

=end
describe 'CLI::parse' do
  before :each do
    defined?(CLI::ARGS) || CLI::ARGS = Hash.new
    CLI::ARGS[:options] = Hash.new
    CLI::ARGS[:params]  = Array.new
  end

  it 'répond' do
    expect(CLI).to respond_to :parse
  end
  
  it 'parse les commandes correctement' do
    expect(CLI::ARGS[:params]).to be_empty
    ARGV.replace ['-r', '--steps=signin', 'test', '--as=visitor', './mon/app']
    CLI.parse
    expect(CLI::ARGS[:params].count).to eq(2)
    expect(CLI::ARGS[:params][0]).to eq('test')
    expect(CLI::ARGS[:params][1]).to eq('./mon/app')
  end

  # TODO Tester ici toutes les options possibles
  it 'parse l’option -dg' do
    expect(CLI::ARGS).to_not have_key :'debug-level'
    expect(CLI::ARGS).to_not have_key :debug
    ARGV.replace ['build', '-dg']
    CLI.parse
    options = CLI::ARGS[:options]
    expect(options).to_not have_key :debug
    expect(options[:debug_level]).to_not eq(nil)
    #                                        ^
    #                                        |
    # la vraie valeur est testée + bas ------+
  end
  it 'parse l’option :debug en la mettant dans :debug_level' do
    expect(CLI::ARGS).to_not have_key :'debug-level'
    expect(CLI::ARGS).to_not have_key :debug
    ARGV.replace ['build', '--debug']
    CLI.parse
    options = CLI::ARGS[:options]
    expect(options).to_not have_key :debug
    expect(options[:debug_level]).to_not eq(nil)
  end
  it 'parse l’option --random' do
    expect(CLI::ARGS).to_not have_key :random
    ARGV.replace ['build','--random']
    CLI.parse
    expect(CLI::ARGS[:options][:random]).to be true
  end
  it 'parse l’option -r en --random' do
    ARGV.replace ['check','-r']
    expect(CLI::ARGS[:options]).to_not have_key :random
    CLI.parse
    expect(CLI::ARGS[:options]).to have_key :random
    expect(CLI::ARGS[:options][:random]).to be true
  end

  it 'parse l’option --wait' do
    ARGV.replace ['check', '--wait=3.1']
    expect(CLI::ARGS[:options]).to_not have_key :wait
    CLI.parse
    expect(CLI::ARGS[:options][:wait]).to eq(3.1)
  end
  it 'parse l’option -w (wait)' do
    ARGV.replace ['check', '-w=2.2']
    expect(CLI::ARGS[:options]).to_not have_key :wait
    CLI.parse
    expect(CLI::ARGS[:options][:wait]).to eq(2.2)
  end

  it 'parse l’option --build' do
    ARGV.replace ['ckeck', '--build']
    expect(CLI::ARGS[:options]).not_to have_key :build
    CLI.parse
    expect(CLI::ARGS[:options][:build]).to be true
  end

  it 'parse l’option -b (build)' do
    ARGV.replace ['ckeck', '-b']
    expect(CLI::ARGS[:options]).not_to have_key :build
    CLI.parse
    expect(CLI::ARGS[:options][:build]).to be true
  end

  it 'parse l’option --path' do
    ARGV.replace ['test', '--path=./mon/app']
    expect(CLI::ARGS[:options]).to_not have_key :path
    CLI.parse
    expect(CLI::ARGS[:options][:path]).to eq './mon/app'
  end
  it 'parse l’option -p' do
    ARGV.replace ['test', '-p=./mon/autre/app']
    expect(CLI::ARGS[:options]).to_not have_key :path
    CLI.parse
    expect(CLI::ARGS[:options][:path]).to eq './mon/autre/app'
  end


  
  describe 'Valeurs par défaut des options' do
    it 'sont définies même sans options' do
      ARGV.replace ['check']
      CLI.parse
      options = CLI::ARGS[:options]
      expect(options).not_to be_empty
      # Pour voir les options et les débugguer
      #puts options.inspect, true 
      expect(options[:wait]).to eq(1)
      expect(options[:debug_level]).to eq(0)
      expect(options[:fail_fast]).to eq(false)
    end
    
  end
end

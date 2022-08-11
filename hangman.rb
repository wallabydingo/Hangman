class Hangman

  require 'io/console'
  require 'yaml'

  attr_accessor :level, :available_letters, :secret_word, :hidden_word, :chances

  def new_game
    @level = 0
    @dictionary = '10000-english-no-swears.txt'
    @available_letters = ('A'..'Z').to_a
    @secret_word = ''
    @hidden_word = ''
    @chances = 10
    choose_level
    select_secret_word
  end

  def start
    puts '', 'Continue saved game?'
    response = gets.chomp.downcase
    if response == 'yes'
      load_game
      puts '', "#{@chances} chances left."
    else
      new_game
    end
    play_game
  end

  def choose_level
    puts 'Difficulty level? (1~10)'
    @level = gets.chomp.to_i + 4
    until (5..14).include?(@level)
      puts 'Enter level 1 to 10'
      @level = gets.chomp.to_i + 4
    end
  end

  def sort_words
    words = File.open (@dictionary)
    sorted_dict = Hash.new []
    words.each do |word|
      sorted_dict[word.chomp.length] += [word.chomp]
    end
    sorted_dict
  end

  def select_difficulty(sorted_words, level)
    sorted_words[level]
  end

  def select_secret_word
    sorted_words = sort_words
    word_list = select_difficulty(sorted_words, @level)
    @secret_word = word_list.sample.upcase
  end

  def guess_letter
    puts 'You have not tried these letters yet..'
    puts @available_letters.join(' ')
    puts '', 'Guess a letter...or "SAVE"'
    letter = gets.chomp.upcase
    if letter == 'SAVE'
      save_game
    end
    until ('A'..'Z').include?(letter)
      puts 'Just ONE LETTER, idiot!'
      letter = gets.chomp
    end
    unless @secret_word.include?(letter)
      @chances -= 1
      if @chances > -1
        puts "No match! #{@chances} chances left."
      else
        puts '', 'You lose!', "The word was #{@secret_word}.", ''
      end
    end
    @available_letters.delete(letter)
  end

  def hide_word
    available_letters = self.available_letters
    @hidden_word = @secret_word
    available_letters.each do |letter|
      @hidden_word = @hidden_word.gsub(letter, '_')
    end
  end

  def play_game
    until @chances == -1
      hide_word
      if @secret_word == @hidden_word
        puts '', 'You got it!', "!!! #{@hidden_word} !!!", ''
        break
      end
      puts '', @hidden_word.split('').join(' '), ''
      guess_letter
    end
  end

  def save_game
    puts 'Save as...'
    saved_name = gets.chomp.downcase
    while saved_name.match? /\W/
      puts 'Only letters and numbers...'
      saved_name = gets.chomp.downcase
    end
    File.open("./saved_games/#{saved_name}.yml", 'w') { |f| YAML.dump([] << self, f) }
    puts '', 'Game saved, goodbye.', ''
    exit
  end

  def load_game
    begin
      puts '', 'Saved games:'
      files = Dir.glob('./saved_games/*.yml')
      files.each { |file| puts File.basename(file, '.yml') }
      puts '', 'Which one?'
      saved_file = gets.chomp.downcase
      yaml = YAML.load_file("./saved_games/#{saved_file}.yml")
      @level = yaml[0].level
      @available_letters = yaml[0].available_letters
      @secret_word = yaml[0].secret_word
      @hidden_word = yaml[0].hidden_word
      @chances = yaml[0].chances
    rescue
      puts '', 'Something went wrong.', 'Start new game...', ''
      new_game
    end
  end

end

game = Hangman.new

game.start

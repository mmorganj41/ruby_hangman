require 'yaml'

class Game
    attr_reader :guesses, :guess_count, :secret_word, :guessed_word, :won

    def initialize
        puts 'Hangman Loaded'
    end

    def create_word_dictionary(filename)
        # Create word dictionary from file
        # Get rid of next line character and only include words between 5 and 12 long

        words = File.readlines(filename)
        words.reject!{|w| w.length < 6 || w.length > 13}.map! do |w|
            w.gsub("\n", '')
        end
        @words = words
    end

    def select_secret_word
        @secret_word = @words.sample
    end

    def new_game(guess_count)
        @guess_count = guess_count
        select_secret_word
        @guessed_word = select_secret_word.gsub(/\w/, '_')
        @guesses = []
        @won = false
    end

    def guessletter(letter)
        good_guess = false
        @secret_word.each_char.with_index do |c, i|
            if c == letter
                good_guess = true
                @guessed_word[i] = c
            end
        end       

        if good_guess
            puts "Correct!"
        else
            @guesses.push(letter)
            puts "Incorrect!"
        end

    end
    
    def guessloop
        puts "Current Word: #{@guessed_word.split('').join(' ')}\n"

        while true
            puts "Guessed letters:"
            puts @guesses.join(', ')
            puts "Guess a letter (guesses remaining #{@guess_count-@guesses.length}) -type 'save' to save game:"
            guess = gets.downcase.chomp
            
            if guess == 'save'
                puts "Type filename:"
                filename = gets.chomp
                to_yaml(filename)
                puts "Saved!"
            elsif (guess =~ /^[a-z]$/).nil?
                puts "Guess a letter"
            elsif guessed_word.include?(guess) || guesses.include?(guess)
                puts "Already guessed this letter"
            else
                break
            end
        end

        guessletter(guess)
    end

    def check_won
        @won = true if @guessed_word == @secret_word
    end

    def play_game
        while @guess_count > @guesses.length && !@won
            guessloop
            check_won
        end
        if @won
            puts "You won!"
        else
            puts "The secret word was: #{@secret_word} Try again!"
        end
        puts "Play again? (y/n)"
        again = gets.downcase.chomp
        if again == 'y'
            puts "\n"
            new_game(7)
            play_game
        end
    end

    def to_yaml(filename)
        File.write("./saves/#{filename}.yaml", YAML.dump({
            guesses: @guesses,
            secret_word: @secret_word,
            guess_count: @guess_count,
            guessed_word: @guessed_word
        }))
    end

    def from_yaml(filename)
        data = YAML.load(File.read("./saves/#{filename}.yaml"))
        @guess_count = data[:guess_count]
        @secret_word = data[:secret_word]
        @guesses = data[:guesses]
        @guessed_word = data[:guessed_word]
        @won = false
    end
end
        

game = Game.new()
game.create_word_dictionary('dictionary.txt')
puts "Load game? (y/n)"
load = gets.downcase.chomp
if load == 'y'
    while true
        puts "Type file name (q to start a new game)"
        filenames = Dir.glob('saves/*').map {|file| file[(file.index('/') + 1 )...(file.index('.'))]}
        puts filenames
        filename = gets.chomp
        if File.exist?("./saves/#{filename}.yaml")
            game.from_yaml(filename)
            puts game.guesses
            puts game.guess_count
            break
        elsif filename == 'q'
            game.new_game(7)
        else
            puts "file does not exist"
        end
    end    
else
    game.new_game(7)
end

game.play_game

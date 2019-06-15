require "yaml"

def read_file
	arr = []
	File.open("5desk.txt").each do |line|
		word = line.gsub("\n", "")
		if word.length >= 5 && word.length <= 12
			arr << word
		end
	end

	arr
end

def get_random_word (array)
	array[Random.rand(array.length - 1)]
end

class Game
	attr_accessor :word, :word_array, :guessed_word_array, :guess, :tries, :uncorrect_guesses, :game_saved

	def initialize
		@word = get_random_word(read_file)
		@word_array = @word.split("")
		@guessed_word_array = Array.new(@word_array.length, "_")
		@tries = @word.length + 6
		@uncorrect_guesses = []
		@game_saved = false
		display_greetings
		File.exists?("save.yml") ? get_game_choice : play_game
	end

	def display_greetings
		puts "******** Welcome to The Hangman Game! ********"
		puts "You need to guess the correct word in #{@tries} moves"
		puts "***************** Good luck! *****************"
	end

	def get_game_choice
		input = nil
		loop do
			puts "What do you want to do?"
			puts "1. Play new game | 2. Load game"
			input = gets.chomp
			break if input == "1" || input == "2"
		end
		input == "1" ? play_game : load_game
	end

	def load_game
		save = YAML.load_file("save.yml")		
		@word = save.word
		@word_array = save.word_array
		@guessed_word_array = save.guessed_word_array
		@tries = save.tries
		@uncorrect_guesses = save.uncorrect_guesses
		play_game
	end

	def display_board
		board = @guessed_word_array.join(" ")
		puts "Current state: #{board}"
		puts "Uncorrect guesses: #{@uncorrect_guesses.join(", ")}"
	end

	def valid_input? (guess)
		(guess.length == 1 && guess.match(/[a-z]/) && !@uncorrect_guesses.include?(guess)) || guess == "1"
	end

	def get_input
		loop do
			puts "Tries remaining: #{@tries}"
			puts "Please, type your guess: (A-Z, a-z) or '1' to save the game"
			@guess = gets.chomp.downcase
			break if valid_input?(@guess)
		end
		save_game if @guess == "1"
	end

	def update_board
		@word_array.each_with_index do |char, index|
			if char == @guess
				@guessed_word_array[index] = char 
			else
				@uncorrect_guesses << @guess if !@uncorrect_guesses.include?(@guess)
			end
		end
	end

	def game_ended?
		@tries <= 0 || !@guessed_word_array.include?('_')
	end

	def save_game
		save = YAML::dump(self)
		File.open("save.yml", "w+") { |file| file.write(save) }
		@game_saved = true
	end

	def play_again
		input = nil
		loop do
			puts "Do you want to play again? (Y/N)"
			input = gets.chomp.upcase
			break if input == "Y" || input == "N"
		end
		input == "Y"
	end

	def play_game
		loop do
			display_board
			get_input
			@tries -= 1
			update_board

			break if game_ended? || game_saved
		end

		if !game_saved
			puts game_ended? ? "Congratulations, you won!" : "You lost!"
			puts "Secret word was: #{@word}"
			puts "Your guess was: #{@guessed_word_array.join("")}"
		end
		
		play_again ? Game.new : (puts "Thank you for playing!")
	end

end

game = Game.new


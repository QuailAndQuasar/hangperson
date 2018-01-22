require 'awesome_print'

class Hangperson
  attr_accessor :target_word
  attr_accessor :misses
  attr_accessor :guesses
  attr_accessor :remaining_choices
  attr_accessor :game_state
  attr_accessor :show_messages
  attr_reader :word

  # Number of tries until Game Over by failure.
  DEATH_COUNT = 6
  SOURCE_FILE = 'words.txt'
  # SOURCE_FILE = 'words_controlled.txt'.freeze

  def initialize(show_messages=true)
    # we can turn messages
    @show_messages = show_messages

    # ACTIVE, WIN, LOSE
    @game_state = 'ACTIVE'
    @word = nil
    @target_word = nil

    # as guesses are made, they will be removed from
    # their remaining choices.  It starts as the full alphabet
    # @remaining_choices = 'abcdefghijklmnopqrstuvwxyz'.split(//)
    @remaining_choices = [*?a..?z]
    # Sets the word and it's related variables
    apply_word(choose_word)

    # a running tally of ALL the letters (bot hits and misses)
    # that have been guessed
    @guesses = []

    # a tally of incorrect guesses
    @misses = []
  end

  # @word : the word we are trying to guess.
  # @target_word :
  # the target string that begins 'blank'. The letters will be filled in
  # as the user guesses correctly.
  #
  # ex) @word = 'misfits'
  #     @target_word = '_______'
  #
  # The target word has the same number of characters
  # as the word.   So, after guessing 'i' and 'm' we see:
  # irb => puts @target_word
  # => 'mi_f_ts'
  def apply_word(word)
    @word = word
    @target_word = '_' * @word.length
  end

  # Pick a random word from our source file
  def choose_word
    word = File.readlines(SOURCE_FILE).sample.chomp
    # This is for dev.  REMOVE
    puts ":::: SECRET :::: Word to Solve: #{word}"
    word.rstrip.downcase
  end

  def death_count
    DEATH_COUNT
  end

  # returns
  def process_guess(char)
    update_remaining_choices(char)
    update_guess_tally(char)

    # find all indecies of that char
    indecies = @word.enum_for(:scan, /#{char}/)
                    .map { Regexp.last_match.begin(0) }
    indecies != [] ? record_hit(char, indecies) : record_miss(char)
    assess_game
  end

  def update_remaining_choices(char)
    @remaining_choices.delete(char)
  end

  # In hangman, this is the metric we use when we
  # Draw the head, body, arm...etc
  def update_guess_tally(char)
    @guesses << char
  end

  def record_hit(char, indecies)
    # update the target word to show their progress
    indecies.each { |i| @target_word[i] = char }
  end

  def record_miss(char)
    @misses << char
  end

  def assess_game
    if check_solved
      @game_state = 'WIN'
      pardon_human if @show_messages
    elsif check_loss
      @game_state = 'LOSE'
      hang_a_human_because_of_vocabulary if @show_messages
    else
      @game_state = 'ACTIVE'
      show_status
    end
    @game_state
  end

  def check_solved
    true unless @target_word.index('_')
  end

  def check_loss
    @misses.length >= DEATH_COUNT
  end

  def show_status
    puts ''
    puts '---------------- GAME STATUS--------------------------'
    puts "Incorrect guesses: #{@misses}"
    puts "All guesses: #{@guesses}"
    puts "Remaining choices: #{@remaining_choices}"
    puts "Chances Left: #{(DEATH_COUNT - @misses.count)}"
    puts '---------------- GAME STATUS--------------------------'
    puts ''
  end

  def hang_a_human_because_of_vocabulary
    puts '************  Final Notice  ********************'
    puts 'Unfortunately, you have been put to death.'
    puts 'You had not been performant in solving our standardized "life/death" puzzle.'
    puts 'This outcome has been ruled upon and may not be appealed.'
    puts 'You will be charged a standard "rope" charge of $9.00.'
    puts '************  Final Notice  ********************'
  end

  def pardon_human
    puts '************  Congratulations  ********************'
    puts 'You have guessed a word correctly. As a result, you will not hang.'
    puts 'You may go home alive.'
    puts 'Please speak to Janet at the front desk if you need'
    puts 'your parking validated.'
    puts '************  Congratulations  ********************'
  end

  def print_banner
    puts ''
    puts '***********************************'
    puts 'H A N G P E R S O N'
    puts ''
    puts 'Figure out these words....'
    puts '                .......or say your last.'
    puts '***********************************'
    puts ''
  end
end

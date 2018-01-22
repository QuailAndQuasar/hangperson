require_relative '../../lib/hangperson'

require 'awesome_print'
require 'minitest/autorun'
require 'pry'

class HangpersonTest < Minitest::Test
  def test_word_is_not_empty
    game = Hangperson.new(show_messages: false)
    assert(!game.word.nil?, 'The word is empty.')
  end

  def test_update_choices
    game = Hangperson.new(show_messages: false)
    game.update_remaining_choices('q')
    assert(true, game.remaining_choices.index('q').nil?.to_s)
  end

  def test_ignore_duplicate_entry
    game = Hangperson.new(show_messages: false)
    game.apply_word('dingo')
    game.process_guess('d')
    assert(true, game.remaining_choices.index('d').nil?)
  end

  def test_game_progress
    game = Hangperson.new(show_messages: false)
    original_target_word = '_' * game.word.length
    word = game.word
    # Take two of the word's letters
    valid_choices = word.split(//).uniq.sample(2)
    ap valid_choices
    # simulate a user guessing two matching letters
    valid_choices.each do |guess_char|
      game.process_guess(guess_char)
    end
    # Prove the difference by deleting all remaining blank spaces.
    # from target_word after having been processed
    difference = game.target_word.delete(original_target_word)
    updated_letters = difference.split(//).uniq
    assert(updated_letters - valid_choices == [], 'Progress String not updated.')
  end

  def test_game_ends_at_death_count
    game = Hangperson.new(show_messages: false)
    game.apply_word('zippo')
    misses = [*?a..?g]
    misses.each do |guess_char|
      game.process_guess(guess_char)
    end

    assert(game.game_state == 'LOSE', 'Game should have ended in Loss.')
  end

  def test_game_ends_at_puzzle_success
    game = Hangperson.new(show_messages: false)
    game.target_word = game.word
    game.assess_game
    assert(game.game_state == 'WIN', 'Game should have ended in a Win.')
  end
end

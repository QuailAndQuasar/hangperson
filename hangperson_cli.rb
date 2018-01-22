#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'highline/import'
require_relative 'lib/hangperson'
puts 'begin....'

@continue = true
@game = Hangperson.new
@game.print_banner
@guess_character = ''

loop do
  @guess_character = ask('Pick a letter...', String) do |tries|
  # @guess_character = ask('Pick a letter...') do |tries|
    tries.gather = 1
    tries.verify_match = true
    # tries.responses[:not_in_word] = "#{tries} isn't in the word."
  end

  say "You guessed #{@guess_character}"
  break unless @game.remaining_choices.index(@guess_character)
  result = @game.process_guess(@guess_character)
  puts "RESULT: #{result}"
  @continue = false unless result == 'ACTIVE'
  break unless @continue
end
puts 'goodbye.'

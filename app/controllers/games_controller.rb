class GamesController < ApplicationController
  def game
    grid_size = 12
    @grid = generate_grid(grid_size)
    @start_time = DateTime.now

  end

  def score
    @user_input = params[:user_guess]
    @grid = params[:grid]
    @start_time = params[:start_time]
    @end_time = DateTime.now
    @time_difference = @end_time - @start_time.to_datetime
    @result = score_and_message(@user_input, @grid, @time_difference)
  end
end


private

require 'open-uri'
require 'json'

def generate_grid(grid_size)
  Array.new(grid_size) { ('A'..'Z').to_a.sample }
end

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end


def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end

def english_word?(word)
  response = open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end

class Api::V1::AchievementController < ApplicationController
  before_action :authenticate_request!, only: %i[achieve]
  def achieve
    user = User.find(params[:id])
    testcase_count = user.projects.joins(versions: { test_cases: :result }).count
    rank = calculate_rank(testcase_count)
    range_difference = calculate_range_difference(rank, testcase_count)
    achieve = {
      user_id: user.id,
      user: user.name,
      testcase_count:,
      rank: { name: rank, range_difference: }
    }
    render json: achieve
  end

  private

  def calculate_rank(testcase_count)
    case testcase_count
    when 0..99
      'Beginner'
    when 100..999
      'Intermediate'
    when 1000..1999
      'Advanced'
    else
      'Mastery'
    end
  end

  def calculate_range_difference(rank, testcase_count)
    range_max = case rank
                when 'Beginner'
                  99
                when 'Intermediate'
                  999
                when 'Advanced'
                  1999
                else
                  Float::INFINITY
                end

    range_difference = range_max - testcase_count
    # range_difference.positive? ? range_difference : 0
  end
end

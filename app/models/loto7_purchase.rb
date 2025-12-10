class Loto7Purchase < ApplicationRecord
  validates :number_set, presence: true
  validate :validate_number_set_format
  validates :price, presence: true, numericality: { equal_to: 300 }

  # 全期間の当選実績を集計
  def self.total_winning_statistics
    draws = Loto7WinningResult.total_draws
    total_purchase = draws * 1500  # 1回の抽選で5口（1500円）
    statistics = {
      total_purchase: total_purchase,
      total_winning: 0,
      balance: 0,
      by_rank: Hash.new { |h, k| h[k] = { count: 0, amount: 0 } }
    }

    all.each do |purchase|
      Loto7WinningResult.all.each do |result|
        if win_info = purchase.check_result(result)
          rank = win_info[:rank]
          prize = win_info[:prize]
          statistics[:by_rank][rank][:count] += 1
          statistics[:by_rank][rank][:amount] += prize
          statistics[:total_winning] += prize
        end
      end
    end

    statistics[:balance] = statistics[:total_winning] - statistics[:total_purchase]
    statistics
  end

  def purchase_numbers
    number_set.split(',').map(&:to_i).sort
  end

  def self.total_amount
    sum(:price)
  end

  def check_result(winning_result)
    # Add Ruby frozen_string_literal comment
    # frozen_string_literal: true

    return nil unless winning_result

    main_numbers = winning_result.main_numbers
    bonus_numbers = winning_result.bonus_numbers
    matched_main = (purchase_numbers & main_numbers).size
    matched_bonus = (purchase_numbers & bonus_numbers).size

    case
    when matched_main == 7
      { rank: 1, prize: winning_result.prize_1 }
    when matched_main == 6 && matched_bonus >= 1
      { rank: 2, prize: winning_result.prize_2 }
    when matched_main == 6
      { rank: 3, prize: winning_result.prize_3 }
    when matched_main == 5
      { rank: 4, prize: winning_result.prize_4 }
    when matched_main == 4
      { rank: 5, prize: winning_result.prize_5 }
    when matched_main == 3 && matched_bonus >= 1
      { rank: 6, prize: winning_result.prize_6 }
    else
      nil
    end
  end

  def number_matches(winning_result)
    return [] unless winning_result

    main_numbers = winning_result.main_numbers
    bonus_numbers = winning_result.bonus_numbers

    purchase_numbers.map do |number|
      if main_numbers.include?(number)
        'main'
      elsif bonus_numbers.include?(number)
        'bonus'
      else
        'no-match'
      end
    end
  end

  private

  def validate_number_set_format
    numbers = number_set.to_s.split(',').map(&:to_i)
    
    unless numbers.length == 7 &&
           numbers.all? { |n| n.between?(1, 37) } &&
           numbers.uniq.length == 7
      errors.add(:number_set, 'は1から37までの重複しない7つの数字をカンマ区切りで入力してください')
    end
  end
end

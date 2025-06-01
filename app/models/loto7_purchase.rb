class Loto7Purchase < ApplicationRecord
  validates :number_set, presence: true
  validate :validate_number_set_format
  validates :price, presence: true, numericality: { equal_to: 300 }

  def purchase_numbers
    number_set.split(',').map(&:to_i).sort
  end

  def self.total_amount
    sum(:price)
  end

  def number_matches(result)
    purchase_numbers.map do |number|
      if result.main_numbers.include?(number)
        'main'
      elsif result.bonus_numbers.include?(number)
        'bonus'
      else
        'no-match'
      end
    end
  end

  

  def check_result(winning_result)
    return nil unless winning_result

    main_numbers = winning_result.winning_numbers
    bonus_numbers = winning_result.bonus_numbers
    matched_main = (purchase_numbers & main_numbers).size
    matched_bonus = (purchase_numbers & bonus_numbers).size

    case
    when matched_main == 7
      { rank: 1, prize: winning_result.prize1 }
    when matched_main == 6 && matched_bonus >= 1
      { rank: 2, prize: winning_result.prize2 }
    when matched_main == 6
      { rank: 3, prize: winning_result.prize3 }
    when matched_main == 5
      { rank: 4, prize: winning_result.prize4 }
    when matched_main == 4
      { rank: 5, prize: winning_result.prize5 }
    when matched_main == 3 && matched_bonus >= 1
      { rank: 6, prize: winning_result.prize6 }
    else
      nil
    end
  end

  def number_matches(winning_result)
    return [] unless winning_result

    main_numbers = winning_result.winning_numbers
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

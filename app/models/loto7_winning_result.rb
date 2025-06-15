require 'mechanize'

class Loto7WinningResult < ApplicationRecord
  BALL_COLORS = {
    red: '#e53935',      # 中間赤
    orange: '#f4511e',   # 中間オレンジ
    yellow: '#fdd835',   # 中間黄
    green: '#43a047',    # 中間緑
    blue: '#1e88e5',     # 中間青
    purple: '#8e24aa',   # 中間紫
    pink: '#d81b60'      # 中間ピンク
  }

  SET_BALL_NUMBER_COLORS = {
    'A' => {
      red: [1, 8, 15, 22, 29, 36],
      orange: [2, 9, 16, 23, 30, 37],
      yellow: [3, 10, 17, 24, 31],
      green: [4, 11, 18, 25, 32],
      blue: [5, 12, 19, 26, 33],
      purple: [6, 13, 20, 27, 34],
      pink: [7, 14, 21, 28, 35]
    },
    'B' => {
      red: [7, 14, 21, 28, 35],
      orange: [1, 8, 15, 22, 29, 36],
      yellow: [2, 9, 16, 23, 30, 37],
      green: [3, 10, 17, 24, 31],
      blue: [4, 11, 18, 25, 32],
      purple: [5, 12, 19, 26, 33],
      pink: [6, 13, 20, 27, 34]
    },
    'C' => {
      red: [6, 13, 20, 27, 34],
      orange: [7, 14, 21, 28, 35],
      yellow: [1, 8, 15, 22, 29, 36],
      green: [2, 9, 16, 23, 30, 37],
      blue: [3, 10, 17, 24, 31],
      purple: [4, 11, 18, 25, 32],
      pink: [5, 12, 19, 26, 33]
    },
    'D' => {
      red: [5, 12, 19, 26, 33],
      orange: [6, 13, 20, 27, 34],
      yellow: [7, 14, 21, 28, 35],
      green: [1, 8, 15, 22, 29, 36],
      blue: [2, 9, 16, 23, 30, 37],
      purple: [3, 10, 17, 24, 31],
      pink: [4, 11, 18, 25, 32]
    },
    'E' => {
      red: [4, 11, 18, 25, 32],
      orange: [5, 12, 19, 26, 33],
      yellow: [6, 13, 20, 27, 34],
      green: [7, 14, 21, 28, 35],
      blue: [1, 8, 15, 22, 29, 36],
      purple: [2, 9, 16, 23, 30, 37],
      pink: [3, 10, 17, 24, 31]
    },
    'F' => {
      red: [7, 14, 21, 28, 35],
      orange: [6, 13, 20, 27, 34],
      yellow: [5, 12, 19, 26, 33],
      green: [4, 11, 18, 25, 32],
      blue: [3, 10, 17, 24, 31],
      purple: [2, 9, 16, 23, 30, 37],
      pink: [1, 8, 15, 22, 29, 36]
    },
    'G' => {
      red: [6, 13, 20, 27, 34],
      orange: [5, 12, 19, 26, 33],
      yellow: [4, 11, 18, 25, 32],
      green: [3, 10, 17, 24, 31],
      blue: [2, 9, 16, 23, 30, 37],
      purple: [1, 8, 15, 22, 29, 36],
      pink: [7, 14, 21, 28, 35]
    },
    'H' => {
      red: [5, 12, 19, 26, 33],
      orange: [4, 11, 18, 25, 32],
      yellow: [3, 10, 17, 24, 31],
      green: [2, 9, 16, 23, 30, 37],
      blue: [1, 8, 15, 22, 29, 36],
      purple: [7, 14, 21, 28, 35],
      pink: [6, 13, 20, 27, 34]
    },
    'I' => {
      red: [4, 11, 18, 25, 32],
      orange: [3, 10, 17, 24, 31],
      yellow: [2, 9, 16, 23, 30, 37],
      green: [1, 8, 15, 22, 29, 36],
      blue: [7, 14, 21, 28, 35],
      purple: [6, 13, 20, 27, 34],
      pink: [5, 12, 19, 26, 33]
    },
    'J' => {
      red: [3, 10, 17, 24, 31],
      orange: [2, 9, 16, 23, 30, 37],
      yellow: [1, 8, 15, 22, 29, 36],
      green: [7, 14, 21, 28, 35],
      blue: [6, 13, 20, 27, 34],
      purple: [5, 12, 19, 26, 33],
      pink: [4, 11, 18, 25, 32]
    }
  }

  def get_number_color(number)
    return nil unless set_ball

    SET_BALL_NUMBER_COLORS[set_ball]&.each do |color_key, numbers|
      return BALL_COLORS[color_key] if numbers.include?(number)
    end
    nil
  end

  self.table_name = 'loto7WinningResults'
  
  attr_reader :lottery_round
  scope :newest_first, -> { order(lottery_date: :desc) }

  def winning_numbers
    [
      main_num_1, main_num_2, main_num_3, main_num_4,
      main_num_5, main_num_6, main_num_7
    ].sort
  end

  def main_numbers
    [
      main_num_1, main_num_2, main_num_3, main_num_4,
      main_num_5, main_num_6, main_num_7
    ].sort
  end

  def bonus_numbers
    [bonus_num_1, bonus_num_2].sort
  end

  def formatted_lottery_date
    lottery_date&.strftime('%Y年%m月%d日')
  end

  def lottery_round
    self[:lottery_round]
  end

  def prize_data
    [
      { rank: 1, winners: prize_1_winners, amount: prize_1 },
      { rank: 2, winners: prize_2_winners, amount: prize_2 },
      { rank: 3, winners: prize_3_winners, amount: prize_3 },
      { rank: 4, winners: prize_4_winners, amount: prize_4 },
      { rank: 5, winners: prize_5_winners, amount: prize_5 },
      { rank: 6, winners: prize_6_winners, amount: prize_6 }
    ]
  end

  def self.scrape_latest_results
    agent = Mechanize.new
    page = agent.get('http://sougaku.com/loto7/data/list1/')
    
    results = []
    page.search('table.bun_box2 tr').each do |row|
      cells = row.search('td, th')  # thタグも含めて検索
      next if cells.empty? || cells[0].text.strip == '抽選回' # ヘッダー行をスキップ
      
      # 基本情報の取得
      round = cells[0].text.strip.gsub(/[第回\s]/, '')  # スペースも除去
      next if round.empty?  # 空の行をスキップ
      
      main_numbers = cells[1..7].map { |cell| cell.text.strip.to_i }  # インデックスを1-7に修正
      bonus_numbers = cells[8..9].map { |cell| cell.text.strip.to_i }  # インデックスを8-9に修正
      set_ball = cells[10].text.strip
      
      # 詳細ページのリンクを取得
      detail_link = cells.last.at('a')&.[]('href')
      next unless detail_link && main_numbers.size == 7 && bonus_numbers.size == 2
      
      # 既存のデータをチェック
      next if exists?(lottery_round: round)
      
      # 詳細ページから追加情報を取得
      detail_page = agent.get("http://sougaku.com#{detail_link}")
      
      # 抽選日と販売実績を取得
      info_cells = detail_page.search('table.sokuho_tb1 td')
      lottery_date = Date.strptime(info_cells[1].text.strip[0..-4], '%Y年%m月%d日')
      sales_amount = info_cells[2].text.strip.gsub(/[^\d]/, '').to_i
      
      # 当選金額情報を取得
      prize_cells = detail_page.search('table.sokuho_tb3 td')
      prize_info = extract_prize_info(prize_cells)
      
      # データを作成
      results << create!(
        lottery_round: round,
        main_num_1: main_numbers[0],
        main_num_2: main_numbers[1],
        main_num_3: main_numbers[2],
        main_num_4: main_numbers[3],
        main_num_5: main_numbers[4],
        main_num_6: main_numbers[5],
        main_num_7: main_numbers[6],
        bonus_num_1: bonus_numbers[0],
        bonus_num_2: bonus_numbers[1],
        set_ball: set_ball,
        lottery_date: lottery_date,
        actual_sales_amount: sales_amount,
        **prize_info
      )
    end
    
    results
  rescue StandardError => e
    Rails.logger.error "Failed to scrape Loto7 results: #{e.message}"
    []
  end

  private

  def self.extract_prize_info(cells)
    {
      prize_1_winners: extract_winners(cells[1]),
      prize_1: extract_amount(cells[2]),
      prize_2_winners: extract_winners(cells[5]),
      prize_2: extract_amount(cells[6]),
      prize_3_winners: extract_winners(cells[9]),
      prize_3: extract_amount(cells[10]),
      prize_4_winners: extract_winners(cells[13]),
      prize_4: extract_amount(cells[14]),
      prize_5_winners: extract_winners(cells[17]),
      prize_5: extract_amount(cells[18]),
      prize_6_winners: extract_winners(cells[21]),
      prize_6: extract_amount(cells[22]),
      carry_over: extract_amount(cells[25])
    }
  end

  def self.extract_winners(cell)
    text = cell.text.strip
    text == '該当なし' ? 0 : text.gsub(/[^\d]/, '').to_i
  end

  def self.extract_amount(cell)
    cell.text.strip.gsub(/[^\d]/, '').to_i
  end

  # Prevent NoMethodError when date is nil
  def formatted_date(date)
    date&.strftime('%Y年%m月%d日')
  end
end

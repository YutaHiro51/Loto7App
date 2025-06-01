require 'mechanize'

class Loto7WinningResult < ApplicationRecord
  # Public instance methods
  def formatted_lottery_date
    lottery_date&.strftime('%Y年%m月%d日')
  end

  def main_numbers
    [
      main_num_1, main_num_2, main_num_3, main_num_4,
      main_num_5, main_num_6, main_num_7
    ]
  end

  def bonus_numbers
    [bonus_num_1, bonus_num_2]
  end

  def prize_data
    (1..6).map do |rank|
      {
        rank: rank,
        winners: send("prize_#{rank}_winners"),
        amount: send("prize_#{rank}")
      }
    end
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

  public
  def prize_data
    (1..6).map do |rank|
      {
        rank: rank,
        winners: send("prize_#{rank}_winners"),
        amount: send("prize_#{rank}")
      }
    end
  end

  def main_numbers
    [
      main_num_1, main_num_2, main_num_3, main_num_4,
      main_num_5, main_num_6, main_num_7
    ]
  end

  def bonus_numbers
    [bonus_num_1, bonus_num_2]
  end

  def formatted_lottery_date
    lottery_date&.strftime('%Y年%m月%d日')
  end

  # Prevent NoMethodError when date is nil
  def formatted_date(date)
    date&.strftime('%Y年%m月%d日')
  end
  self.table_name = 'loto7WinningResults'

  scope :newest_first, -> { order(lottery_date: :desc) }

  def winning_numbers
    [
      main_num_1,
      main_num_2,
      main_num_3,
      main_num_4,
      main_num_5,
      main_num_6,
      main_num_7
    ].sort
  end

  def main_numbers
    [
      main_num_1,
      main_num_2,
      main_num_3,
      main_num_4,
      main_num_5,
      main_num_6,
      main_num_7
    ].sort
  end

  def bonus_numbers
    [bonus_num_1, bonus_num_2].sort
  end

  def formatted_lottery_date
    lottery_date.strftime('%Y年%m月%d日')
  end

  def prize_data
    [
      { rank: 1, winners: prize_1_winners, prize: prize_1 },
      { rank: 2, winners: prize_2_winners, prize: prize_2 },
      { rank: 3, winners: prize_3_winners, prize: prize_3 },
      { rank: 4, winners: prize_4_winners, prize: prize_4 },
      { rank: 5, winners: prize_5_winners, prize: prize_5 },
      { rank: 6, winners: prize_6_winners, prize: prize_6 }
    ]
  end
end

class Loto7WinningResultsController < ApplicationController
  def index
    @years = Loto7WinningResult.select("DISTINCT strftime('%Y', lottery_date) as year")
                               .order(year: :desc)
                               .map(&:year)

    current_year = Time.current.year.to_s
    @filter_year = params[:year].presence || (@years.include?(current_year) ? current_year : @years.first)
    @filter_month = params[:month]

    query = Loto7WinningResult.newest_first

    # 年フィルター（常に適用）
    query = query.where("strftime('%Y', lottery_date) = ?", @filter_year)
    
    # 月フィルター（指定がある場合のみ）
    if @filter_month.present?
      query = query.where("strftime('%m', lottery_date) = ?", @filter_month.to_s.rjust(2, '0'))
    end

    @loto7_winning_results = query.all
  end

  def show
    @loto7_winning_result = Loto7WinningResult.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "指定された抽選結果が見つかりません"
    redirect_to loto7_winning_results_path
  end

  def analysis
    @years = Loto7WinningResult.select("DISTINCT strftime('%Y', lottery_date) as year")
                               .order(year: :desc)
                               .map(&:year)

    @filter_year = params[:year]
    @filter_month = params[:month]

    @number_stats = calculate_number_stats(@filter_year, @filter_month)
    
    base_query = Loto7WinningResult.all
    if @filter_year.present?
      base_query = base_query.where("strftime('%Y', lottery_date) = ?", @filter_year)
      if @filter_month.present?
        base_query = base_query.where("strftime('%m', lottery_date) = ?", @filter_month.to_s.rjust(2, '0'))
      end
    end
    @total_draws = base_query.count
    
    @title = "当選数字分析"
  end

  def update_from_web
    results = Loto7WinningResult.scrape_latest_results
    
    if results.any?
      flash[:notice] = "#{results.size}件の抽選結果を追加しました"
    else
      flash[:alert] = "新しい抽選結果はありませんでした"
    end
    
    redirect_to loto7_winning_results_path
  end

  private

  def calculate_number_stats(year = nil, month = nil)
    results = Loto7WinningResult.all

    if year.present?
      results = results.where("strftime('%Y', lottery_date) = ?", year)
      if month.present?
        results = results.where("strftime('%m', lottery_date) = ?", month.to_s.rjust(2, '0'))
      end
    end

    stats = Hash.new(0)
    
    results.each do |result|
      (result.main_numbers + result.bonus_numbers).each do |num|
        stats[num] += 1
      end
    end

    stats.sort_by { |num, count| [-count, num] }.to_h
  end
end

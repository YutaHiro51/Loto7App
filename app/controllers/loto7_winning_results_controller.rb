class Loto7WinningResultsController < ApplicationController
  def index
    @loto7_winning_results = Loto7WinningResult.newest_first.page(params[:page]).per(20)
  end

  def show
    @loto7_winning_result = Loto7WinningResult.find(params[:id])
    Rails.logger.debug "Prize Data: #{@loto7_winning_result.prize_data.inspect}"
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
end

class Loto7PurchasesController < ApplicationController
  def index
    @loto7_purchases = Loto7Purchase.all.order(created_at: :desc)
    @total_amount = Loto7Purchase.total_amount
    if session[:check_results]
      @latest_result = Loto7WinningResult.find(session[:check_results])
      session.delete(:check_results)
    end
  end

  def create
    @purchase = Loto7Purchase.new(purchase_params)
    
    if @purchase.save
      flash[:notice] = "購入番号を登録しました"
    else
      flash[:alert] = @purchase.errors.full_messages.join(", ")
    end
    
    redirect_to loto7_purchases_path
  end

  def destroy
    @purchase = Loto7Purchase.find(params[:id])
    @purchase.destroy
    
    flash[:notice] = "購入番号を削除しました"
    redirect_to loto7_purchases_path
  end

  def check_results
    latest_result = Loto7WinningResult.order(lottery_date: :desc).first
    unless latest_result
      redirect_to loto7_purchases_path, alert: '抽選結果が見つかりません'
      return
    end

    session[:check_results] = latest_result.id
    redirect_to loto7_purchases_path(check: true), notice: '当選結果を確認しました'
  end

  private

  def purchase_params
    params.require(:loto7_purchase).permit(:number_set)
  end
end

class PurchasesController < ApplicationController
  def index
    @purchases = Purchase.all.where(status: 'fraud_pending')
  end

  def pending
    @purchase = Purchase.find(params[:id])

    @purchase.pending!
    redirect_to purchases_path
  end
end

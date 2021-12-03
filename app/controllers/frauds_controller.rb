class FraudsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @purchases = Purchase.all.where(status: 'rejected')
  end

  def show
    @purchase = Purchase.find(params[:purchase_id])
  end

  def new
    @purchase = Purchase.find(params[:purchase_id])
    @fraud = Fraud.new
  end

  def create
    @purchase = Purchase.find(params[:purchase_id])
    @fraud = Fraud.new(fraud_params)

    @fraud.purchase_id = @purchase.id

    if @fraud.save
      @purchase.rejected!
      redirect_to purchases_path
    else
      render :new
    end
  end

  private

  def fraud_params
    params.require(:fraud).permit(:title, :description, :file)
  end
end

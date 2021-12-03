class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_product_and_authenticate_company, only: %i[show enable disable]
  before_action :redirect_if_pending_company
  before_action :authenticate_company_user, only: %i[enable disable]

  def index
    @products = Product.where(company: current_user.company)
  end

  def show; end

  def new
    @product = Product.new
    @product_types_dropdown = Product.product_types_dropdown
  end

  def create
    @product = Product.new(product_params)
    @product_types_dropdown = Product.product_types_dropdown
    @product.company = current_user.company

    if @product.save
      redirect_to @product, notice: t('.create_success_notice')
    else
      render :new
    end
  end

  def disable
    @product.disabled!
    redirect_to @product
  end

  def enable
    @product.enabled!
    redirect_to @product
  end

  private

  def product_params
    params.require(:product).permit(:name, :type_of)
  end
end

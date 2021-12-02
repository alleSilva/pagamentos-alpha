class CompaniesController < ApplicationController
  before_action :authenticate_admin!, only: %i[index pending accept]
  before_action :authenticate_user!, except: %i[index pending accept]
  skip_before_action :redirect_empty_company_users, only: %i[edit update]
  before_action :find_company_and_authenticate_owner, only: %i[edit update cancel_registration]
  before_action :redirect_if_pending_company, only: %i[edit update]
  before_action :find_company, only: %i[show]
  before_action :authenticate_company_user, only: %i[show]
  before_action :authenticate_user_company_accepted, only: %i[payment_settings]

  def index
    @companies = Company.all
  end

  def show; end

  def edit; end

  def update
    if @company.update(edit_company_params)
      @company.pending! if @company.rejected?
      redirect_to @company, notice: t('.complete_success_notice')
    else
      render :edit
    end
  end

  def payment_settings
    @enabled_payment_methods = PaymentMethod.query_for_enabled
    @payment_settings = current_user.company.payment_settings
  end

  def cancel_registration
    @company.blank_all_info!

    redirect_to root_path
  end

  def pending
    @companies = Company.where(status: 'pending')
  end

  def accept
    @company = Company.find(params[:id])

    if admin_signed_in?
      @company.accepted!
      redirect_to companies_path
    else
      redirect_to root_path
    end
  end

  private

  def edit_company_params
    params.require(:company).permit(
      :legal_name,
      :cnpj,
      :billing_email,
      :billing_address
    )
  end
end

class ApplicationController < ActionController::Base
  before_action :redirect_empty_company_users, unless: :devise_controller?

  def authenticate_users!
    return if user_signed_in? || admin_signed_in?

    redirect_to root_path, alert: 'Faça login para ter acesso ao sistema'
  end

  def redirect_empty_company_users
    redirect_to edit_company_path current_user.company if current_user&.incomplete_company?
  end

  def authenticate_user_company_accepted
    authenticate_users!
    return if current_user.accepted_company?

    redirect_to company_path(current_user.company),
                alert: t('companies.not_accepted_alert')
  end

  def find_company_and_authenticate_owner
    find_company

    return if current_user&.owns?(@company)

    redirect_to root_path, alert: t('companies.edit.no_permission_alert')
  end

  def find_product_and_authenticate_company
    @product = Product.find(params[:id])
    @company = @product.company
    return if @company == current_user.company

    redirect_to root_path, alert: t('product.not_linked_to_company_alert')
  end

  def redirect_if_pending_company
    return unless current_user&.company&.pending?

    redirect_to current_user.company, alert: t('companies.not_accepted_alert')
  end

  def find_pix_setting
    @pix_setting = PixSetting.find(params[:id])
    @company = @pix_setting.company
  end

  def find_boleto_setting
    @boleto_setting = BoletoSetting.find(params[:id])
    @company = @boleto_setting.company
  end

  def find_credit_card_setting
    @credit_card_setting = CreditCardSetting.find(params[:id])
    @company = @credit_card_setting.company
  end

  def find_company
    @company = Company.find(params[:id])
  end

  def authenticate_company_user
    return if current_user&.in_company?(@company)

    redirect_to root_path, alert: t('companies.show.no_permission_alert')
  end
end

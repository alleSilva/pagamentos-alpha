class ApplicationController < ActionController::Base
  before_action :redirect_empty_company_users

  def redirect_empty_company_users
    redirect_to edit_company_path current_user.company if current_user&.incomplete_company?
  end

  def find_company_and_authenticate_owner
    find_company

    return if current_user&.owns?(@company)

    redirect_to root_path, alert: t('companies.edit.no_permission_alert')
  end

  def redirect_if_pending_company
    return unless @company.pending?

    redirect_to @company
  end

  def find_company
    @company = Company.find(params[:id])
  end

  def authenticate_company_user
    find_company

    return if current_user&.in_company?(@company)

    redirect_to root_path, alert: t('companies.show.no_permission_alert')
  end
end

class HomeController < ApplicationController
  def index
    redirect_to admin_dashboard_path if admin_signed_in?
    redirect_to company_path(current_user.company.id) if user_signed_in? && current_user.company.accepted?
  end
end

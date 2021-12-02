class RejectedCompaniesController < ApplicationController
  before_action :authenticate_admin!

  def new
    @company = Company.find(params[:company_id])
    @rejected_company = RejectedCompany.new
  end

  def create
    @company = Company.find(params[:company_id])
    @rejected_company = RejectedCompany.new(rejeted_company_params)
    @rejected_company.company = @company

    if @rejected_company.save
      @company.rejected!
      redirect_to companies_path
    else
      render :new
    end
  end

  private

  def rejeted_company_params
    params.require(:rejected_company).permit(:reason)
  end
end

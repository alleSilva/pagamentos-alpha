class BoletoSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_user_company_accepted
  before_action :find_boleto_setting, only: %i[enable disable]
  before_action :authenticate_company_user, only: %i[enable disable]

  def new
    @payment_methods_dropdown = PaymentMethod.payment_methods_by_type_dropdown('boleto')
    @boleto_setting = BoletoSetting.new
  end

  def create
    @boleto_setting = BoletoSetting.new(**boleto_params, company: current_user.company)
    @payment_methods_dropdown = PaymentMethod.payment_methods_by_type_dropdown('boleto')

    if @boleto_setting.save
      redirect_to company_payment_settings_path(current_user.company), notice: t('payment_settings.created_notice')
    else
      render :new
    end
  end

  def disable
    @boleto_setting.disabled!

    redirect_to company_payment_settings_path @boleto_setting.company
  end

  def enable
    @boleto_setting.enabled!

    redirect_to company_payment_settings_path @boleto_setting.company
  end

  private

  def boleto_params
    params.require(:boleto_setting).permit(:agency_number, :account_number, :bank_code, :payment_method_id)
  end
end

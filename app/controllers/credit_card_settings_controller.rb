class CreditCardSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_user_company_accepted
  before_action :find_credit_card_setting, only: %i[enable disable]
  before_action :authenticate_company_user, only: %i[enable disable]

  def new
    @payment_methods_dropdown = PaymentMethod.payment_methods_by_type_dropdown('credit_card')
    @credit_card_setting = CreditCardSetting.new
  end

  def create
    @payment_methods_dropdown = PaymentMethod.payment_methods_by_type_dropdown('credit_card')
    @credit_card_setting = CreditCardSetting.new(**credit_card_params, company: current_user.company)

    if @credit_card_setting.save
      redirect_to company_payment_settings_path(current_user.company), notice: t('payment_settings.created_notice')
    else
      render :new
    end
  end

  def disable
    @credit_card_setting.disabled!

    redirect_to company_payment_settings_path @credit_card_setting.company
  end

  def enable
    @credit_card_setting.enabled!

    redirect_to company_payment_settings_path @credit_card_setting.company
  end

  private

  def credit_card_params
    params.require(:credit_card_setting).permit(:company_code, :payment_method_id)
  end
end

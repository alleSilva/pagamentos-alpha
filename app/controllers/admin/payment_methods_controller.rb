class Admin
  class PaymentMethodsController < ApplicationController
    before_action :authenticate_users!
    before_action :authenticate_admin!, only: %i[new create show index disable enable]

    def index
      @payment_methods = PaymentMethod.all
    end

    def show
      @payment_method = PaymentMethod.find(params[:id])
    end

    def new
      @payment_method = PaymentMethod.new
      @payment_types_dropdown = PaymentMethod.payment_types_dropdown
    end

    def create
      @payment_method = PaymentMethod.new(payment_method_params)
      @payment_types_dropdown = PaymentMethod.payment_types_dropdown

      if @payment_method.save
        redirect_to [:admin, @payment_method]
      else
        render :new
      end
    end

    def disable
      @payment_method = PaymentMethod.find(params[:id])
      @payment_method.disabled!

      redirect_to [:admin, @payment_method]
    end

    def enable
      @payment_method = PaymentMethod.find(params[:id])
      @payment_method.enabled!

      redirect_to [:admin, @payment_method]
    end

    private

    def payment_method_params
      params.require(:payment_method).permit(:name, :fee, :maximum_fee, :type_of, :icon)
    end
  end
end

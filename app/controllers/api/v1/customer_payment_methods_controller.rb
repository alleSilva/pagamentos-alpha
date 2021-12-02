module Api
  module V1
    class CustomerPaymentMethodsController < Api::V1::ApiController
      def index
        @customer_payment_method = CustomerPaymentMethod.where(company: @company)

        render status: :ok, json: success_json
      end

      def show
        @customer_payment_method = CustomerPaymentMethod.find_by(token: params[:id], company: @company)
        raise ActiveRecord::RecordNotFound if @customer_payment_method.nil?

        render status: :ok, json: success_json
      end

      def create
        sanitized_params = customer_payment_method_params
        credit_card_flag = sanitized_params[:type_of] == 'credit_card'

        @customer_payment_method = CustomerPaymentMethod.new(
          customer_payment_method_basic_params
        )

        add_payment_setting(sanitized_params[:type_of])

        @customer_payment_method.add_credit_card(credit_card_params) if credit_card_flag

        return render status: :created, json: success_json if @customer_payment_method.save

        render status: :unprocessable_entity, json: error_json
      end

      private

      def customer_payment_method_basic_params
        sanitized_params = customer_payment_method_params
        {
          company: @company,
          customer: find_by_token(Customer, sanitized_params[:customer_token]),
          type_of: sanitized_params[:type_of]
        }
      end

      def add_payment_setting(type_of)
        token = customer_payment_method_params[:payment_setting_token]

        setting_hash = { 'pix' => PixSetting, 'boleto' => BoletoSetting, 'credit_card' => CreditCardSetting }
        send_hash = { 'pix' => 'pix_setting=', 'boleto' => 'boleto_setting=', 'credit_card' => 'credit_card_setting=' }

        send_parameter_value = send_hash[type_of]
        setting = find_by_token(setting_hash[type_of], token)

        @customer_payment_method.send(send_parameter_value, setting) unless setting&.disabled?
      end

      def customer_payment_method_params
        params.require(:customer_payment_method).permit(
          :customer_token,
          :payment_setting_token,
          :type_of
        )
      end

      def credit_card_params
        params.require(:customer_payment_method).permit(
          :credit_card_name, :credit_card_number,
          :credit_card_expiration_date, :credit_card_security_code
        )
      end

      def find_payment_method
        payment_setting = @company.find_enabled_payment_setting_by_token(
          customer_payment_method_params[:payment_method_token]
        )
        payment_setting&.payment_method
      end

      def success_json
        @customer_payment_method.as_json(
          only: %i[token type_of],
          include: {
            pix_setting: { only: %i[token type_of] },
            boleto_setting: { only: %i[token type_of] },
            credit_card_setting: { only: %i[token type_of] },
            customer: { only: %i[token] },
            company: { only: %i[legal_name] }
          }
        )
      end

      def error_json
        {
          message: 'Requisição inválida', errors:  @customer_payment_method.errors,
          request: generate_customer_payment_method_request
        }
      end

      def generate_customer_payment_method_request
        @customer_payment_method.as_json(
          only: %i[type_of],
          include: {
            pix_setting: { only: %i[token type_of] }, boleto_setting: { only: %i[token type_of] },
            credit_card_setting: { only: %i[token type_of] },
            customer: { only: %i[token] }, company: { only: %i[legal_name] }
          }
        )
      end
    end
  end
end

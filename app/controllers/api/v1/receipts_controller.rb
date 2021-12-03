module Api
  module V1
    class ReceiptsController < Api::V1::ApiController
      skip_before_action :authenticate_company!, only: :show

      def index
        # TODO: deve ter um jeito melhor de fazer isso
        customer_payment_methods = CustomerPaymentMethod.where(company: @company)
        purchases = Purchase.where(customer_payment_method: customer_payment_methods)
        @receipt = Receipt.where(purchase: purchases)

        render status: :ok, json: success_json
      end

      def show
        @receipt = find_by_token!(Receipt, params[:id])

        render status: :ok, json: success_json
      end

      private

      def success_json
        @receipt.as_json(
          only: %i[token authorization_code],
          include: { purchase: { only: %i[expiration_date paid_date],
                                 include: { customer_payment_method: { only: %i[type_of] },
                                            product: { only: %i[name token] },
                                            company: { only: %i[legal_name] } } } }
        )
      end
    end
  end
end

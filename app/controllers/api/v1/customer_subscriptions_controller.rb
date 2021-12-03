module Api
  module V1
    class CustomerSubscriptionsController < Api::V1::ApiController
      def show
        @customer_subscription = find_by_token(CustomerSubscription, params[:id])
        raise ActiveRecord::RecordNotFound if @customer_subscription.nil?

        render status: :ok, json: success_json
      end

      def index
        @customer_subscription = CustomerSubscription.where(company: @company)

        render status: :ok, json: success_json
      end

      def create
        @customer_subscription = CustomerSubscription.new(
          customer_subscription_basic_params
        )

        @customer_subscription.validate_product_is_not_single

        if @customer_subscription.errors.empty? && @customer_subscription.save
          return render status: :created, json: success_json
        end

        render status: :unprocessable_entity, json: error_json
      end

      private

      def customer_subscription_params
        params.require(:customer_subscription).permit(:customer_payment_method_token, :subscription_token, :cost)
      end

      def customer_subscription_basic_params
        sanitized_params = customer_subscription_params

        customer_payment_method = find_by_token(CustomerPaymentMethod,
                                                sanitized_params[:customer_payment_method_token])
        subscription = find_by_token(Product, sanitized_params[:subscription_token])
        {
          cost: sanitized_params[:cost],
          company: @company,
          customer_payment_method: customer_payment_method,
          product: subscription
        }
      end

      def success_json
        @customer_subscription.as_json(
          only: %i[token renovation_date status cost],
          include: {
            product: { only: %i[name type_of token] },
            customer_payment_method: { only: %i[token] },
            company: { only: %i[legal_name] }
          }
        )
      end

      def error_json
        {
          message: 'Requisição inválida', errors:  @customer_subscription.errors,
          request: generate_customer_subscription_request
        }
      end

      def generate_customer_subscription_request
        @customer_subscription.as_json(
          only: %i[token renovation_date status cost],
          include: {
            product: { only: %i[name type_of token] },
            customer_payment_method: { only: %i[token] },
            company: { only: %i[legal_name] }
          }
        )
      end
    end
  end
end

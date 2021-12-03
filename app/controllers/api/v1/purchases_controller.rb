module Api
  module V1
    class PurchasesController < Api::V1::ApiController
      def index
        @purchases = Purchase.search(request.query_parameters, @company)

        if @purchases.nil?
          render status: :bad_request, json: { message: 'Parâmetro Inválido' }
        else
          render status: :ok, json: success_json
        end
      end

      def show
        @purchase = Purchase.find_by(token: params[:id])
        raise ActiveRecord::RecordNotFound if @purchase.nil?

        return render_not_authorized if @purchase.company != @company

        render status: :ok, json: success_json
      end

      def create
        @purchase = @company.purchases.new
        add_purchase_basic_properties

        if @purchase.errors.empty? && @purchase.save
          render status: :created, json: success_json
        else
          render status: :unprocessable_entity, json: { message: 'Requisição inválida', errors: @purchase.errors,
                                                        request: @purchase.as_json(except: %i[id token company_id
                                                                                              created_at updated_at]) }
        end
      end

      private

      def purchase_params
        params.require(:purchase).permit(
          :product_token,
          :purchase_payment_method_token,
          :customer_payment_method_token,
          :cost
        )
      end

      def success_json
        json_object = @purchases.nil? ? @purchase : @purchases
        json_object.as_json(except: %i[id customer_payment_method_id pix_setting_id
                                       boleto_setting_id credit_card_setting_id
                                       product_id receipt_id company_id created_at
                                       updated_at],
                            include: { company: { only: :legal_name },
                                       product: { only: %i[name token] },
                                       customer_payment_method: { only: :token } })
      end

      def add_purchase_basic_properties
        sanitized_params = purchase_params
        @purchase.product = find_by_token(Product, sanitized_params[:product_token])
        @purchase.cost = sanitized_params[:cost]
        @purchase.validate_product_is_not_subscription
        @purchase.customer_payment_method = find_by_token(CustomerPaymentMethod,
                                                          sanitized_params[:customer_payment_method_token])
      end
    end
  end
end

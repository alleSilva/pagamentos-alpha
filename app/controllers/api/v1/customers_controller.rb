module Api
  module V1
    class CustomersController < Api::V1::ApiController
      def index
        @customers = Customer.all.where(company: @company)

        render status: :ok, json: @customers.as_json(except: %i[id company_id
                                                                created_at updated_at],
                                                     include: {
                                                       company: { only: :legal_name }
                                                     })
      end

      def show
        @customer = Customer.find_by(token: params[:id])
        raise ActiveRecord::RecordNotFound if @customer.nil?

        return render_not_authorized if @customer.company != @company

        render status: :ok, json: @customer.as_json(except: %i[id company_id
                                                               created_at updated_at],
                                                    include: {
                                                      company: { only: :legal_name },
                                                      customer_payment_methods: { only: %i[type_of token] }
                                                    })
      end

      def create
        @customer = @company.customers.create(customer_params)

        if @customer.save
          render status: :created, json: @customer.as_json(except: %i[id company_id created_at updated_at],
                                                           include: { company: { only: :legal_name } })
        else
          render status: :unprocessable_entity, json: { message: 'Requisição inválida', errors: @customer.errors,
                                                        request: @customer.as_json(except: %i[id token company_id
                                                                                              created_at updated_at]) }
        end
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :cpf)
      end
    end
  end
end

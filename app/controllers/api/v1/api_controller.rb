module Api
  module V1
    class ApiController < ActionController::API
      rescue_from ActiveRecord::ActiveRecordError, with: :render_generic_error
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      ActiveRecord::Base.include_root_in_json = true
      before_action :authenticate_company!

      private

      def find_by_token!(model, token)
        element = model.find_by(token: token)
        raise ActiveRecord::RecordNotFound if element.nil?

        element
      end

      def find_by_token(model, token)
        model.find_by(token: token)
      end

      def authenticate_company!
        @company = Company.find_by(token: request.headers['companyToken'])
        render_not_authorized if @company.nil?
      end

      def render_not_authorized
        render status: :unauthorized, json: { message: 'Há algo errado com sua autenticação.' }
      end

      def render_not_found(_exception)
        render status: :not_found, json: { message: 'Objeto não encontrado' }
      end

      def render_generic_error(_exception)
        render status: :internal_server_error, json: { message: 'Erro geral' }
      end
    end
  end
end

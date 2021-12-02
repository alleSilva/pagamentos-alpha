module Api
  module V1
    class CreditCardSettingsController < Api::V1::ApiController
      before_action :authenticate_company!

      def index
        @credit_card_settings = CreditCardSetting.includes(:payment_method).where(company: @company,
                                                                                  payment_method: { status: :enabled })

        render json: @credit_card_settings.as_json(
          except: %i[created_at updated_at property_type_id company_id payment_method_id],
          include: { payment_method: { only: %i[
            name id
          ] } }
        )
      end

      def show
        @credit_card_setting = find_by_token!(CreditCardSetting, params[:id])

        return render_not_authorized if @credit_card_setting&.company != @company

        render json: @credit_card_setting.as_json(
          except: %i[created_at updated_at property_type_id company_id payment_method_id],
          include: { payment_method: { only: %i[
            name id status
          ] } }
        )
      end
    end
  end
end

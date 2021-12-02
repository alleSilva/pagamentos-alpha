module Api
  module V1
    class PixSettingsController < Api::V1::ApiController
      def index
        @pix_settings = PixSetting.includes(:payment_method).where(company: @company,
                                                                   payment_method: { status: :enabled })

        render json: @pix_settings.as_json(
          except: %i[created_at updated_at property_type_id company_id payment_method_id],
          include: { payment_method: { only: %i[name
                                                id] } }
        )
      end

      def show
        @pix_setting = find_by_token!(PixSetting, params[:id])

        return render_not_authorized if @pix_setting&.company != @company

        render json: @pix_setting.as_json(
          except: %i[created_at updated_at property_type_id company_id payment_method_id],
          include: { payment_method: { only: %i[name id
                                                status] } }
        )
      end
    end
  end
end

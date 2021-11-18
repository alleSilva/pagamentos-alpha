class Users::RegistrationsController < Devise::RegistrationsController
    protected

    def sign_up_params
        params = devise_parameter_sanitizer.sanitize(:sign_up)
        params["owner"] = true
        params
    end
end

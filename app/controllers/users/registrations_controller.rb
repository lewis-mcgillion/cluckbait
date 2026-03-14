module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def after_sign_up_path_for(_resource)
      root_path
    end

    def update_resource(resource, params)
      if params[:password].present? || (params[:email].present? && params[:email] != resource.email)
        resource.update_with_password(params)
      else
        resource.update_without_password(params.except(:current_password))
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :display_name)
    end

    def account_update_params
      params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :display_name, :bio,
:avatar)
    end
  end
end

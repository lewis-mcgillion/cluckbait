module Users
  class PasswordsController < Devise::PasswordsController
    def create
      if params.dig(:user, :email).blank?
        self.resource = resource_class.new
        resource.errors.add(:email, :blank)
        respond_with(resource)
      else
        super
      end
    end
  end
end

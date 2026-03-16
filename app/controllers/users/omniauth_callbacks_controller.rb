module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      handle_omniauth("Google")
    end

    def failure
      redirect_to new_user_session_path, alert: t("devise.omniauth_callbacks.failure", kind: failed_strategy_name,
        reason: failure_message)
    end

    private

    def handle_omniauth(provider_name)
      auth = request.env["omniauth.auth"]

      social_account = SocialAccount.find_by(provider: auth.provider, uid: auth.uid)

      if social_account
        sign_in_existing(social_account, provider_name)
      elsif current_user
        link_to_current_user(auth, provider_name)
      else
        create_or_link_user(auth, provider_name)
      end
    end

    def sign_in_existing(social_account, provider_name)
      user = social_account.user
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    end

    def link_to_current_user(auth, provider_name)
      social_account = current_user.social_accounts.build(social_account_params(auth))

      if social_account.save
        redirect_to edit_user_registration_path,
          notice: t("devise.omniauth_callbacks.linked", kind: provider_name)
      else
        redirect_to edit_user_registration_path,
          alert: t("devise.omniauth_callbacks.link_failed", kind: provider_name)
      end
    end

    def create_or_link_user(auth, provider_name)
      email = auth.info.email
      existing_user = User.find_by(email: email) if email.present?

      if existing_user
        link_and_sign_in(existing_user, auth, provider_name)
      else
        create_new_user(auth, provider_name)
      end
    end

    def link_and_sign_in(user, auth, provider_name)
      user.social_accounts.create!(social_account_params(auth))
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    end

    def create_new_user(auth, provider_name)
      user = User.new(
        email: auth.info.email || "",
        display_name: auth.info.name || auth.info.first_name || provider_name,
        password: Devise.friendly_token(32)
      )

      if auth.info.image.present?
        begin
          attach_oauth_avatar(user, auth.info.image)
        rescue StandardError
          # Skip avatar if download fails
        end
      end

      user.social_accounts.build(social_account_params(auth))

      if user.save
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
      else
        session["devise.omniauth_data"] = { provider: auth.provider, uid: auth.uid, info: auth.info.to_h }
        redirect_to new_user_registration_path,
          alert: t("devise.omniauth_callbacks.create_failed", kind: provider_name)
      end
    end

    def social_account_params(auth)
      {
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        access_token: auth.credentials&.token,
        refresh_token: auth.credentials&.refresh_token,
        token_expires_at: auth.credentials&.expires_at ? Time.zone.at(auth.credentials.expires_at) : nil
      }
    end

    def failed_strategy_name
      request.env["omniauth.error.strategy"]&.name&.to_s&.humanize || "Unknown"
    end

    ALLOWED_AVATAR_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
    MAX_AVATAR_SIZE = 5.megabytes

    def attach_oauth_avatar(user, image_url)
      uri = URI.parse(image_url)
      return unless uri.is_a?(URI::HTTPS)

      avatar_io = uri.open(
        "User-Agent" => "Cluckbait/1.0",
        :open_timeout => 5,
        :read_timeout => 5
      )

      return if avatar_io.size > MAX_AVATAR_SIZE
      return unless ALLOWED_AVATAR_TYPES.include?(avatar_io.content_type)

      user.avatar.attach(
        io: avatar_io,
        filename: "avatar.#{avatar_io.content_type.split('/').last}",
        content_type: avatar_io.content_type
      )
    end
  end
end

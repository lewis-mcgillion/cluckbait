class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :set_sentry_context

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  private

  def set_locale
    locale = params[:locale] ||
             (current_user&.locale if user_signed_in?) ||
             session[:locale] ||
             I18n.default_locale
    I18n.locale = I18n.available_locales.map(&:to_s).include?(locale.to_s) ? locale.to_sym : I18n.default_locale
  end

  def record_not_found
    render "errors/not_found", status: :not_found
  end

  def set_sentry_context
    return unless user_signed_in?
    return unless defined?(Sentry)

    Sentry.set_user(id: current_user.id, username: current_user.display_name)
  end
end

class LocaleController < ApplicationController
  def update
    locale = params[:locale_preference]
    if I18n.available_locales.map(&:to_s).include?(locale)
      if user_signed_in?
        current_user.update(locale: locale)
      end
      I18n.locale = locale.to_sym
    end

    redirect_back fallback_location: root_path(locale: locale), allow_other_host: false
  end
end

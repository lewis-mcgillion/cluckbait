require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cluckbait
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # i18n configuration
    config.i18n.default_locale = :en
    config.i18n.available_locales = [
      :en, :zh, :hi, :es, :fr, :ar, :pt, :ru, :ja,
      :de, :jv, :ko, :vi, :tr, :ur, :it,
      :th, :fa, :pl, :su, :ha, :my,
      :uk, :ms, :tl, :nl, :ro, :yo, :ig, :am, :cs, :el,
      :hu, :sv, :he, :sw, :id, :ne, :si, :ps, :cy, :ga,
      :bg, :hr, :da, :et, :fi, :is, :lv, :lt, :mk, :mt,
      :nb, :sk, :sl, :sq, :sr, :be, :bs, :ka, :hy, :az,
      :ca, :eu, :gl, :gd, :lb
    ]
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    # ActiveRecord Encryption (for OAuth tokens and other sensitive data)
    config.active_record.encryption.primary_key =
      ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] || "dev-primary-key"
    config.active_record.encryption.deterministic_key =
      ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] || "dev-deterministic-key"
    config.active_record.encryption.key_derivation_salt =
      ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] || "dev-key-derivation-salt"
  end
end

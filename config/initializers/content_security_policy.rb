# Be sure to restart your server when you modify this file.

# Content Security Policy – restrict which origins the browser may load
# resources from.  Only the external services actually consumed by the
# application are allow-listed:
#
#   unpkg.com                   – Leaflet JS & CSS
#   fonts.googleapis.com        – Google Fonts stylesheet
#   fonts.gstatic.com           – Google Fonts font files
#   *.tile.openstreetmap.org    – OpenStreetMap tile images
#
# See https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, "https://*.tile.openstreetmap.org"
    policy.object_src  :none
    policy.script_src  :self, "https://unpkg.com"
    policy.style_src   :self, "https://unpkg.com", "https://fonts.googleapis.com"
    policy.connect_src :self
  end

  # Generate per-request nonces for importmap inline scripts and inline styles.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end

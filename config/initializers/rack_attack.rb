class Rack::Attack
  # Throttle login attempts by IP address
  throttle("logins/ip", limit: 10, period: 60.seconds) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle login attempts by email (normalize to lowercase)
  throttle("logins/email", limit: 10, period: 60.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle signup attempts by IP
  throttle("signups/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  # Throttle password reset requests by IP
  throttle("password_resets/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  # General request throttle by IP (300 requests per 5 minutes)
  throttle("requests/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets", "/up")
  end

  # Return 429 with Retry-After header
  self.throttled_responder = lambda do |matched, _period, _limit, request|
    match_data = request.env["rack.attack.match_data"]
    retry_after = match_data[:period] - (Time.now.to_i % match_data[:period])

    [
      429,
      { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
      ["Rate limit exceeded. Retry in #{retry_after} seconds.\n"]
    ]
  end
end

class JsonWebToken
  ALGORITHM = "HS256"
  DEFAULT_EXPIRY = 24.hours

  def self.encode(payload, expires_at: DEFAULT_EXPIRY.from_now)
    token_payload = payload.merge(exp: expires_at.to_i)

    JWT.encode(token_payload, Rails.application.secret_key_base, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: ALGORITHM).first
  end
end

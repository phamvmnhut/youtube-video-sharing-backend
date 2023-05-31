class JsonWebTokenService
  def self.encode(payload)
    JWT.encode payload, ENV.fetch("SECRET_KEY_BASE", nil),
    'HS256'
  end
  def self.decode(token)
    JWT.decode( token, ENV.fetch("SECRET_KEY_BASE", nil),
    algorithm: 'HS256')[0]
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode payload, ENV.fetch("SECRET_KEY_BASE", nil),
    'HS256'
  end

end

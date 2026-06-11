require 'rails_helper'

RSpec.describe JsonWebToken do
  describe ".encode" do
    it "returns a signed JWT with an expiry" do
      token = described_class.encode({ sub: "user-id" }, expires_at: 1.hour.from_now)

      payload = described_class.decode(token)

      expect(payload["sub"]).to eq("user-id")
      expect(payload["exp"]).to be_present
    end
  end

  describe ".decode" do
    it "raises when the token is expired" do
      token = described_class.encode({ sub: "user-id" }, expires_at: 1.hour.ago)

      expect { described_class.decode(token) }.to raise_error(JWT::ExpiredSignature)
    end
  end
end

require "net/http"
require "json"

class OauthService::Google < ActiveInteraction::Base
  hash :auth do
    string :id_token
  end

  def execute
    token_info = get_token_info

    if valid_token_info?(token_info)
      @user = User.where(provider: "google_oauth2", uid: token_info["sub"]).first_or_create do |newUser|
        newUser.provider = token_info["google_oauth2"]
        newUser.uid = token_info["sub"]

        newUser.save
      end

      @user.email = token_info["email"]
      @user.image = token_info["image"]
      @user.name = "#{token_info['given_name']} #{token_info['family_name']}"
      @user.save
    end

    @user.create_new_auth_token if @user&.valid?
  end

  private

  def register

  end

  def get_token_info
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{auth['id_token']}"
    resp = Net::HTTP.get(URI.parse(url))
    JSON.parse(resp)
  end

  def valid_token_info?(token_info)
    has_error = token_info[:error_description].present?
    has_aud_mismatch = token_info["aud"] != Rails.application.secrets["google_ios_client_id"]

    !(has_error || has_aud_mismatch)
  end
end

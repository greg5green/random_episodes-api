class Api::V1::OauthSignInsController < Api::V1::ApiController
  def google
    outcome = OauthService::Google.run(auth: google_params)
    puts(outcome.to_json)
    render_service(outcome: outcome)
  end

  private

  def google_params
    params.permit(:id_token).to_h
  end
end

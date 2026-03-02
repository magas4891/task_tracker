# frozen_string_literal: true

# X's token endpoint (api.x.com/2/oauth2/token) sometimes returns 503 Service Unavailable.
# Retry the token exchange a few times with backoff to improve success rate.
Rails.application.config.to_prepare do
  OmniAuth::Strategies::Twitter2.class_eval do
    alias_method :build_access_token_original, :build_access_token

    def build_access_token
      retries = 0
      max_retries = 2
      begin
        build_access_token_original
      rescue ::OAuth2::Error => e
        status = e.response.respond_to?(:status) ? e.response.status : nil
        if retries < max_retries && status == 503
          retries += 1
          sleep(2 * retries)
          retry
        end
        raise
      end
    end
  end
end

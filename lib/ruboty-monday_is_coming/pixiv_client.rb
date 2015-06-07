require 'json'
require 'net/http'
require 'net/https'
require 'open-uri'

module Ruboty
  module MondayIsComing
    class PixivClient
      USER_AGENT = "ruboty-monday_is_coming"
      ACCESS_TOKEN_RETRIEVE_INTERVAL = 3000

      CLIENT_ID = "bYGKuGVw91e0NMfPGp44euvGt59s"
      CLIENT_SECRET = "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK"

      OAUTH_TOKEN_URL = URI.parse("https://oauth.secure.pixiv.net/auth/token").freeze

      def initialize(login, password)
        @login, @password = login, password
        @access_token = nil
        @access_token_issued_at = nil

        @lock = Mutex.new
      end

      def work(id, image_sizes: %w(large), include_stats: true)
        params = {
          "image_sizes" => image_sizes.join(?,),
          "include_stats" => (!!include_stats).inspect,
        }

        url = URI.parse("https://public-api.secure.pixiv.net/v1/works/#{id.to_i}.json")
        url.query = URI.encode_www_form(params)

        request_get(url)
      end

      def tag(tag, **kwargs)
        works q: tag, mode: :exact_tag, **kwargs
      end

      def works(q:, mode: , per_page: 30, page: 1, order: :desc, sort: :date, period: :all, include_sanity_level: true, include_stats: true, image_sizes: %w(px_480mw large), profile_image_sizes: %w(px_170x170))
        params = {
          q: q.to_s,
          mode: mode.to_s,
          per_page: per_page.to_s,
          page: page.to_s,
          order: order.to_s,
          sort: sort.to_s,
          period: period.to_s,
          include_sanity_level: (!!include_sanity_level).inspect,
          include_stats: (!!include_stats).inspect,
          image_sizes: image_sizes.join(?,),
          profile_image_sizes: profile_image_sizes.join(?,),
        }

        url = URI.parse("https://public-api.secure.pixiv.net/v1/search/works.json")
        url.query = URI.encode_www_form(params)

        request_get(url)
      end

      def access_token
        if !@access_token || (Time.now - @access_token_issued_at) > ACCESS_TOKEN_RETRIEVE_INTERVAL
          issued_at = @access_token_issued_at
          @lock.synchronize do
            if !@access_token || issued_at < @access_token_issued_at
              @access_token = get_access_token
              @access_token_issued_at = Time.now
            end
          end
        end

        @access_token
      end

      private

      def request_get(url, headers = headers())
        Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
          resp = http.request_get(url.request_uri, headers).tap(&:value)
          JSON.parse(resp.body)
        end
      end

      def headers
        {
          "Referer" => "http://spapi.pixiv-app.net",
          "User-Agent" => USER_AGENT,
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Bearer #{access_token}"
        }
      end

      def get_access_token
        headers = {
          "Referer" => "http://www.pixiv.net",
        }
        params = {
          "username" => @login,
          "password" => @password,
          "grant_type" => "password",
          "client_id" => CLIENT_ID,
          "client_secret" => CLIENT_SECRET,
        }

        Net::HTTP.start(OAUTH_TOKEN_URL.host, OAUTH_TOKEN_URL.port, use_ssl: true) do |http|
          resp = http.request_post(OAUTH_TOKEN_URL.request_uri, URI.encode_www_form(params), headers).tap(&:value)
          json = JSON.parse(resp.body)
          json["response"]["access_token"]
        end
      end
    end 
  end
end


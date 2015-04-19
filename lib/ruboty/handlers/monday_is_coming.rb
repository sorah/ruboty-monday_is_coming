# coding: utf-8
require 'ruboty/handlers/base'
require 'open-uri'
require 'uri'
require 'csv'

module Ruboty
  module Handlers
    class MondayIsComing < Base
      on(/月曜日?(?:よりの使者)?/, name: 'show', description: '日高愛ちゃん')
      on(/monday(?:\s+is\s+coming)?/, name: 'show', description: '日高愛ちゃん')

      CACHE_TTL = 120
      def initialize(*)
        super
        @illusts_cache = nil
        @illusts_cached_at = 0
      end

      def show(message)
        message.reply image_url
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      private

      def image_url
        illusts.sample[:mobile_thumbnail_max_width_480]
      end

      def illusts
        if !@illusts_cache || (Time.now - @illusts_cached_at) > CACHE_TTL
          @illusts_cache = illusts_without_cache()
          @illusts_cached_at = Time.now
        end
        @illusts_cache
      end

      PIXIV_TARGET_TAG = "月曜日よりの使者"
      PIXIV_TARGET_AUTHOR_ID = "2493100"
      def illusts_without_cache
        pixiv_search_tag(PIXIV_TARGET_TAG).select { |_| _[:user_id] == PIXIV_TARGET_AUTHOR_ID }
      end

      PIXIV_SPAPI_SEARCH_TAG_URL = 'http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%s'
      def pixiv_search_tag(tag)
        result = open(PIXIV_SPAPI_SEARCH_TAG_URL % [URI.encode_www_form_component(tag)], 'r', &:read)
        lines = CSV.parse(result)
        lines.map do |line|
          {
            id: line[0],
            user_id: line[1],
            extension: line[2],
            image_title: line[3],
            image_directory: line[4],
            artist_nickname: line[5],
            mobile_thumbnail_128_url: line[6],
            mobile_thumbnail_max_width_480: line[9],
            uploaded_at: line[12],
            tags: line[13],
            software: line[14],
            ratings_count: line[15],
            score: line[16],
            views: line[17],
            image_description: line[18],
            pages_count: line[19],
            favorites_count: line[22],
            comments_count: line[23],
            artist_username: line[24],
            r18: line[26],
            series_id: line[27],
            mobile_profile_image: line[29],
          }
        end
      end
    end
  end
end

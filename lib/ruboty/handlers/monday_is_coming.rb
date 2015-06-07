# coding: utf-8
require 'ruboty/handlers/base'
require 'ruboty-monday_is_coming/pixiv_client'
require 'time'

module Ruboty
  module Handlers
    class MondayIsComing < Base
      env 'PIXIV_LOGIN', 'pixiv user id, or email', optional: false
      env 'PIXIV_PASSWORD', 'pixiv password', optional: false

      on(/月曜日?(?:よりの使者)?/, name: 'show', description: '日高愛ちゃん')
      on(/monday(?:\s+is\s+coming)?/, name: 'show', description: '日高愛ちゃん')

      CACHE_TTL = 120
      def initialize(*)
        super
        @illusts_cache = nil
        @illusts_cached_at = 0
        @pixiv = Ruboty::MondayIsComing::PixivClient.new(ENV['PIXIV_LOGIN'], ENV['PIXIV_PASSWORD'])
      end

      def show(message)
        message.reply image_url
      rescue Exception => e
        message.reply "#{e.inspect}\n\t#{e.backtrace.join("\n\t")}"
      end

      private

      def image_url
        time = Time.now
        illust = if time.monday?
          beg = Time.local(time.year, time.month, time.day, 0, 0, 0, '+09:00')
          illusts.select { |_| t = Time.parse("#{_['created_time']} +09:00") rescue nil; next unless t; t >= beg }.min || illusts.sample
        else
          illusts.sample
        end
        illust['image_urls']['px_480mw']
      end

      def illusts
        if !@illusts_cache || (Time.now - @illusts_cached_at) > CACHE_TTL
          @illusts_cache = illusts_without_cache()
          @illusts_cached_at = Time.now
        end
        @illusts_cache
      end

      PIXIV_TARGET_TAG = "月曜日よりの使者"
      PIXIV_TARGET_AUTHOR_ID = 2493100
      def illusts_without_cache
        @pixiv.tag(PIXIV_TARGET_TAG, image_sizes: %w(px_480mw))['response'].select { |_| _['user']['id'] == PIXIV_TARGET_AUTHOR_ID }
      end
    end
  end
end

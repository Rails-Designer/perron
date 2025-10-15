# frozen_string_literal: true

module Perron
  class Resource
    module ReadingTime
      extend ActiveSupport::Concern

      def estimated_reading_time(wpm: DEFAULT_WORDS_PER_MINUTE, format: DEFAULT_FORMAT)
        word_count = content.scan(/\b[a-zA-Z]+\b/).size
        total_minutes = [(word_count.to_f / wpm).ceil, 1].max

        hours = total_minutes / 60
        minutes = total_minutes % 60
        seconds = ((word_count.to_f / wpm) * 60).to_i % 60

        return total_minutes if format.blank?

        format % {
          minutes: minutes,
          total_minutes: total_minutes,
          hours: hours,
          seconds: seconds,
          min: minutes,
          h: hours,
          s: seconds
        }
      end
      alias_method :reading_time, :estimated_reading_time

      private

      DEFAULT_WORDS_PER_MINUTE = 200
      DEFAULT_FORMAT = "%{minutes} min read"
    end
  end
end

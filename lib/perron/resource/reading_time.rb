# frozen_string_literal: true

module Perron
  class Resource
    module ReadingTime
      extend ActiveSupport::Concern

      def estimated_reading_time(wpm: DEFAULT_WORDS_PER_MINUTE, format: DEFAULT_FORMAT)
        word_count = word_count_for(content)
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

      # Words are runs of letters, combining marks (Indic vowel signs, Arabic
      # diacritics, Thai tone marks) and numbers, so any Unicode digit counts
      # too (`\p{N}`). Han, Hiragana and Katakana are written without spaces,
      # so each of those characters counts as one word.
      CJK = /[\p{Han}\p{Hiragana}\p{Katakana}]/
      WORD = /[\p{L}\p{M}\p{N}]+(?:['’]\p{L}+)?/

      def word_count_for(text)
        text.scan(CJK).size + text.gsub(CJK, " ").scan(WORD).size
      end

      DEFAULT_WORDS_PER_MINUTE = 200
      DEFAULT_FORMAT = "%{minutes} min read"
    end
  end
end

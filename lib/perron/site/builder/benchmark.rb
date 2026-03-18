# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Benchmark
        def initialize
          @phases = {}
          @page_times = []
          @start_time = nil
        end

        def start
          @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def phase(name)
          @phases[name] ||= {duration: 0, start: nil}
          @phases[name][:start] = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          yield
        ensure
          if @phases[name][:start]
            @phases[name][:duration] += Process.clock_gettime(Process::CLOCK_MONOTONIC) - @phases[name][:start]
            @phases[name][:start] = nil
          end
        end

        def record_page(path, duration)
          @page_times << {path: path, duration: duration}
        end

        def total_duration
          return 0 unless @start_time

          Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
        end

        def summary
          total = total_duration

          puts "\n"
          puts "Build Performance"
          puts "=" * 60

          @phases.each do |name, data|
            percentage = (total > 0) ? (data[:duration] / total * 100) : 0
            bar = render_bar(percentage)

            puts "  #{name.ljust(25)} #{format("%6.2fs", data[:duration])}  #{bar} #{percentage.round(1)}%"
          end

          puts "-" * 60
          puts "  Total pages: #{@page_times.size}"
          puts "  Avg per page: #{format("%.3fs", average_page_time)}" if @page_times.any?
          puts "  Pages/second: #{pages_per_second.round(1)}" if @page_times.any? && total > 0

          if @page_times.size > 5
            puts "\n  Slowest pages:"

            sorted = @page_times.sort_by { |entry| entry[:duration] }
            sorted.last(5).reverse_each do |entry|
              puts "    #{entry[:path].ljust(40)} #{format("%6.3fs", entry[:duration])}"
            end
          end

          puts "\n"
          puts "  TOTAL: #{format("%.2fs", total)}"
          puts "=" * 60
        end

        private

        def average_page_time
          return 0 unless @page_times.any?

          @page_times.sum { |entry| entry[:duration] } / @page_times.size
        end

        def pages_per_second
          return 0 if @page_times.empty? || total_duration.zero?

          @page_times.size / total_duration
        end

        def render_bar(percentage, width: 20)
          filled = (percentage / 100 * width).round
          empty = width - filled

          "#{"█" * filled}#{"░" * empty}"
        end
      end
    end
  end
end

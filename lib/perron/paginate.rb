# frozen_string_literal: true

module Perron
  class Paginate
    def initialize(collection, page:, per_page:, base_path: nil, page_path_template: nil, use_query_params: false)
      @collection = collection
      @per_page = per_page
      @base_path = base_path
      @page_path_template = page_path_template || "/page/:page/"
      @use_query_params = use_query_params

      @total_items = collection.size
      @total_pages = total_items.zero? ? 0 : (total_items.to_f / per_page).ceil
      @current_page = page.clamp(1, total_pages.zero? ? 1 : total_pages)
    end

    attr_reader :current_page, :total_pages, :total_items, :per_page

    def items
      offset = (@current_page - 1) * @per_page

      @collection[offset, @per_page] || []
    end

    def next? = @current_page < @total_pages

    def previous? = @current_page > 1

    def next
      return unless next?

      page_path(@current_page + 1)
    end

    def previous
      return unless previous?

      target = (@current_page == 2) ? 1 : @current_page - 1

      page_path(target)
    end

    private

    attr_reader :use_query_params

    def page_path(number)
      return if number < 1
      return if number > @total_pages && @total_pages > 0

      return @base_path if number <= 1

      return "#{@base_path}?page=#{number}" if @use_query_params

      @base_path.sub(/\/$/, "") + @page_path_template.sub(":page", number.to_s)
    end
  end
end

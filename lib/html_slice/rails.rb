# frozen_string_literal: true

module HtmlSlice
  module Rails
    def self.included(base)
      base.class_eval do
        include ActionView::RecordIdentifier
        include ActionView::Helpers::FormHelper
        include ActionView::Helpers::FormOptionsHelper
        include ActionView::Helpers::TranslationHelper
        include ActionView::Helpers::UrlHelper
        include ::Rails.application.routes.url_helpers
        include HtmlSlice

        def controller
          nil
        end

        def slice(slice_id = HtmlSlice::DEFAULT_SLICE, &block)
          html_slice(slice_id, &block).html_safe
        end
      end
    end
  end
end

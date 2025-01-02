class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include HtmlSlice
  include ActionView::Helpers::CsrfHelper
  include ActionView::Helpers::CspHelper

  def html(&block)
    html_slice(&block).html_safe
  end

  def layout
    html_layout {
      tag :head do
        title
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        meta name: "apple-mobile-web-app-capable", content: "yes"
        meta name: "mobile-web-app-capable", content: "yes"
        _ csrf_meta_tags
        _ csp_meta_tag

        link rel: "icon", href: "/icon.png", type: "image/png"
        link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
        link rel: "apple-touch-icon"

        _ helpers.stylesheet_link_tag :app, "data-turbo-track": "reload"
        _ helpers.javascript_importmap_tags
      end

      tag :body do
        yield
        5.times do
          partial_a
          partial_b
          partial_c
        end
      end
    }.html_safe
  end

  def partial_a
    tag :p, "Partial a"
  end

  def partial_b
    tag :p, "Partial b"
  end

  def partial_c
    tag :p, "Partial c"
  end
end

# frozen_string_literal: true

require_relative "html_slice/version"
require "cgi"

module HtmlSlice
  class Error < StandardError; end

  TAGS = %i[
    div title embed meta br a em b i ul ol li img table tbody thead tr th td
    form input button link h1 h2 h3 h4 h5 h6 hr span label iframe template main
    footer aside source section small nav area
  ].freeze

  EMPTY_TAGS = %i[
    area br embed hr img input link meta source
  ].to_set.freeze

  TAGS_WITHOUT_HTML_ESCAPE = %i[
    style script
  ].to_set.freeze

  DEFAULT_SLICE = :default

  def html_layout(html_slice_current_id = DEFAULT_SLICE, &block)
    html_slice(
      html_slice_current_id,
      wrap: ["<!DOCTYPE html><html>", "</html>"],
      &block
    )
  end

  def html_slice(html_slice_current_id = DEFAULT_SLICE, wrap: ["", ""], &block)
    @html_slice_current_id = html_slice_current_id
    @html_slice ||= {}

    if block
      buffer = String.new(capacity: 2048)
      buffer << wrap[0]
      @html_slice[@html_slice_current_id] = buffer
      instance_eval(&block)
      buffer << wrap[1]
    end

    (@html_slice[@html_slice_current_id] || "").to_s
  end

  TAGS.each do |name|
    define_method(name) { |*args, &block| tag(name, *args, &block) }
  end

  TAGS_WITHOUT_HTML_ESCAPE.each do |name|
    define_method(name) do |*args, &block|
      content, attributes = parse_html_tag_arguments(args, escape: false)
      generate_and_append_html_tag(name, content, attributes, &block)
    end
  end

  def _(content)
    ensure_html_slice
    @html_slice[@html_slice_current_id] << content.to_s
  end

  def tag(tag_name, *args, &block)
    content, attributes = parse_html_tag_arguments(args)
    generate_and_append_html_tag(tag_name, content, attributes, &block)
  end

  private

  def ensure_html_slice
    @html_slice ||= {}
    @html_slice_current_id ||= DEFAULT_SLICE
    @html_slice[@html_slice_current_id] ||= String.new(capacity: 1024)
  end

  def parse_html_tag_arguments(args, escape: true)
    content = ""
    attributes = {}

    first = args.shift
    if first.is_a?(String)
      content = escape && !first.empty? ? CGI.escapeHTML(first) : first
      attributes = args.pop || {}
    elsif first.is_a?(Hash)
      attributes = first
    end

    [content, attributes]
  end

  def generate_and_append_html_tag(tag_name, content, attributes, &block)
    ensure_html_slice
    buffer = @html_slice[@html_slice_current_id]
    buffer << "<" << tag_name.to_s

    unless attributes.empty?
      attributes.each do |key, value|
        buffer << " " << key.to_s.tr("_", "-") << "='" << value.to_s << "'"
      end
    end

    if block
      buffer << ">"
      instance_eval(&block)
      buffer << "</" << tag_name.to_s << ">"
    elsif content.empty? && EMPTY_TAGS.include?(tag_name)
      buffer << "/>"
    else
      buffer << ">" << content << "</" << tag_name.to_s << ">"
    end
  end
end

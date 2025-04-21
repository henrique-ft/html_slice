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

  # Generates a full HTML document with DOCTYPE
  def html_layout(slice_id = DEFAULT_SLICE, &block)
    html_slice(slice_id, wrap: ["<!DOCTYPE html><html>", "</html>"], &block)
  end

  def html_slice(slice_id = DEFAULT_SLICE, wrap: ["", ""], &block)
    @html_slice_current_id = slice_id
    @html_slice ||= {}

    if block
      buffer = +""
      buffer << wrap[0]
      @html_slice[slice_id] = buffer
      instance_eval(&block)
      buffer << wrap[1]
    end

    @html_slice[slice_id].to_s
  end

  TAGS_WITHOUT_HTML_ESCAPE.each do |tag_name|
    name_str = tag_name.to_s.freeze
    define_method(name_str) do |*args, &block|
      content, attrs = parse_args(args, escape: false)
      render_tag(name_str, tag_name, content, attrs, &block)
    end
  end

  (TAGS - TAGS_WITHOUT_HTML_ESCAPE.to_a).each do |tag_name|
    name_str = tag_name.to_s.freeze
    define_method(name_str) do |*args, &block|
      content, attrs = parse_args(args, escape: true)
      render_tag(name_str, tag_name, content, attrs, &block)
    end
  end

  def tag(tag_name, *args, &block)
    content, attrs = parse_args(args, escape: true)
    render_tag(tag_name.to_s, tag_name, content, attrs, &block)
  end

  def _(text)
    @html_slice[@html_slice_current_id] << text.to_s
  end

  private

  def parse_args(args, escape: true)
    content = ""
    attributes = {}
    first = args[0]
    if first.is_a?(String)
      content = escape && !first.empty? ? CGI.escapeHTML(first) : first
      attributes = args.size > 1 ? args[-1] : {}
    elsif first.is_a?(Hash)
      attributes = first
    end
    [content, attributes]
  end

  def render_tag(name_str, tag_sym, content, attributes, &block)
    @html_slice ||= {}
    @html_slice_current_id ||= DEFAULT_SLICE
    @html_slice[@html_slice_current_id] ||= +""
    buffer = @html_slice[@html_slice_current_id]

    buffer << "<" << name_str
    unless attributes.empty?
      attributes.each do |key, value|
        buffer << " " << key.to_s.tr("_", "-") << "='" << value.to_s << "'"
      end
    end

    if block
      buffer << ">"
      instance_exec(&block)
      buffer << "</#{name_str}>"
    elsif content.empty? && EMPTY_TAGS.include?(tag_sym)
      buffer << "/>"
    else
      buffer << ">" << content << "</#{name_str}>"
    end
  end
end


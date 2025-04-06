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
  ].freeze

  TAGS_WITHOUT_HTML_ESCAPE = %i[
    style script
  ].freeze

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
      @html_slice[@html_slice_current_id] = wrap[0].dup
      instance_eval(&block)
      @html_slice[@html_slice_current_id] << wrap[1]
    end

    @html_slice[@html_slice_current_id] || ""
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
    @html_slice[@html_slice_current_id] ||= +""
  end

  def parse_html_tag_arguments(args, escape: true)
    content = +""
    attributes = {}

    first = args.shift
    if first.is_a?(String)
      content = escape ? CGI.escapeHTML(first) : first
      attributes = args.pop || {}
    elsif first.is_a?(Hash)
      attributes = first
    end

    [content, attributes]
  end

  def generate_and_append_html_tag(tag_name, content, attributes, &block)
    ensure_html_slice
    open_tag = build_html_open_tag(tag_name, attributes)

    if block
      @html_slice[@html_slice_current_id] << open_tag << ">"
      instance_eval(&block)
      @html_slice[@html_slice_current_id] << "</#{tag_name}>"
    elsif content.empty? && EMPTY_TAGS.include?(tag_name)
      @html_slice[@html_slice_current_id] << open_tag << "/>"
    else
      @html_slice[@html_slice_current_id] << open_tag << ">" << content << "</#{tag_name}>"
    end
  end

  def build_html_open_tag(tag_name, attributes)
    return "<#{tag_name}" if attributes.empty?

    attr_string = attributes.map do |key, value|
      " #{key.to_s.tr("_", "-")}='#{value}'"
    end.join

    "<#{tag_name}#{attr_string}"
  end
end

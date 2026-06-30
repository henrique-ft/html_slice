# frozen_string_literal: true

require_relative "html_slice/rails"
require_relative "html_slice/version"
require "cgi"

module HtmlSlice
  class Error < StandardError; end

  TAGS = %i[
    div title embed meta br a em b i ul ol li img table tbody thead tr th td strong
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

  ATTRIBUTE_KEY_CACHE = {}

  STR = {
    empty: "",
    space: " ",
    underline: "_",
    dash: "-",
    single_quote: "-",
    doctype_html: "<!DOCTYPE html><html>",
    end_html: "</html>",
    gt: ">",
    gt_slash: "/>",
    lt: "<",
    lt_slash: "</",
  }.freeze

  def self.slice(slice_id = DEFAULT_SLICE, wrap: [STR[:empty], STR[:empty]], &block)
    @class ||= Class.new { include HtmlSlice }.new
    @class.html_slice(slice_id, wrap: wrap, &block)
  end

  def self.layout(slice_id = DEFAULT_SLICE, &block)
    @class ||= Class.new { include HtmlSlice }.new
    @class.html_layout(slice_id, &block)
  end

  def html_layout(slice_id = DEFAULT_SLICE, &block)
    html_slice(slice_id, wrap: [STR[:doctype_html], STR[:end_html]], &block)
  end

  def html_slice(slice_id = DEFAULT_SLICE, wrap: [STR[:empty], STR[:empty]], &block)
    @html_slice_current_id = slice_id
    @html_slice ||= {}

    if block_given?
      buffer = +STR[:empty]
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

  TAGS.each do |tag_name|
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
    content = STR[:empty]
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
    @html_slice[@html_slice_current_id] ||= +STR[:empty]
    buffer = @html_slice[@html_slice_current_id]

    buffer << STR[:lt] << name_str
    unless attributes.empty?
      attributes.each do |key, value|
        cached_key = ATTRIBUTE_KEY_CACHE[key] ||= key.to_s.tr(STR[:underline], STR[:dash]).freeze
        buffer << STR[:space] << cached_key << "='" << value.to_s << STR[:single_quote]
      end
    end

    if block_given?
      buffer << STR[:gt]
      instance_exec(&block)
      buffer << [STR[:lt_slash], name_str, STR[:gt]].join
    elsif content.empty? && EMPTY_TAGS.include?(tag_sym)
      buffer << STR[:gt_slash]
    else
      buffer << STR[:gt] << content << [STR[:lt_slash], name_str, STR[:gt]].join
    end
  end
end

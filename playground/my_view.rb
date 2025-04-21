require "phlex"
require_relative '../lib/html_slice'

class PhlexView < Phlex::HTML
  def view_template
    navbar
    div do
      h1(some_thing: 'x') { 'hello' }
    end
  end

  def navbar
    ul do
      li { 'hey' }
    end
  end
end

class HtmlSliceView
  include HtmlSlice

  def call
    html_slice do
      navbar
      div do
        h1 'hello', some_thing: 'x'
      end
    end
  end

  def navbar
    ul do
      li 'hey'
    end
  end
end

puts HtmlSliceView.new.call
puts PhlexView.new.call

require 'erubi'
require 'html_slice'
require 'benchmark'

module Partials
  def hello_h1
    h1 'hello'
  end
end

class IndexHtml
  include HtmlSlice
  include Partials

  def call
    html_slice do
      3.times do
        h1 'Benchmark'
        hello_h1
      end
    end
  end
end

Benchmark.bm do |x|
  x.report('html_slice') do
    IndexHtml.new.call
  end

  x.report('(erubi) parsing an erb string') do
    eval(Erubi::Engine.new(%q(
<% 3.times do %>
  <h1> Benchmark </h1>
  <%= eval(Erubi::Engine.new('<h1>hello</h1>').src) %>
<% end %>
                          )).src)
  end

  x.report('(erubi) reading and parsing an erb file') do
    eval(Erubi::Engine.new(File.read("index.html.erb")).src)
  end
end

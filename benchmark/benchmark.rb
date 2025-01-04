# frozen_string_literal: true

require "byebug"
require "benchmark"
require "erubi"
require "html_slice"
require "papercraft"
require "phlex"
require "markaby"

ANY = 100

class TestHtmlSlice
  include HtmlSlice

  def call
    html_layout do
      ANY.times do
        div do
          h1 "Benchmark"
        end
      end
    end
  end
end

class TestPapercraft
  def call
    Papercraft.html {
      ANY.times do
        div do
          h1 "Benchmark"
        end
      end
    }.render
  end
end

class TestMarkaby < Phlex::HTML
  def call
    Markaby::Builder.new.html {
      ANY.times do
        div do
          h1 "Benchmark"
        end
      end
    }.to_s
  end
end

#Can't make it work outside rails =/

#class TestPhlex < Phlex::HTML
  #def view_template
    #ANY.times do
      #h1 "Benchmark"
    #end
  #end
#end

Benchmark.bm do |x|
  x.report("papercraft") do
    TestPapercraft.new.call
  end

  x.report("markaby") do
    TestMarkaby.new.call
  end

  x.report("(erubi) parsing an erb string") do
    eval(Erubi::Engine.new("
<% ANY.times do %>
  <h1> Benchmark </h1>
<% end %>").src)
  end

  x.report("(erubi) reading and parsing an erb file") do
    eval(Erubi::Engine.new(File.read("index.html.erb")).src)
  end

  x.report("html_slice") do
    TestHtmlSlice.new.call
  end
end

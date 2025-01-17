# frozen_string_literal: true

require "benchmark"
require "byebug"
require "erubi"
require "markaby"
require "papercraft"
require "phlex"
require "html_slice"

class RunErubi
  def initialize text = "Benchmark"
    @text = text
  end

  def call
    eval Erubi::Engine.new("<div><h1><%= @text %></h1></div>").src
  end
end

class RunMarkaby
  def initialize text = "Benchmark"
    @text = text
  end

  def call
    Markaby::Builder.new text: @text do
      div do
        h1 @text
      end
    end.to_s
  end
end

class RunPapercraft
  def initialize text = "Benchmark"
    @text = text
  end

  def call
    Papercraft.html do |text:|
      div do
        h1 text
      end
    end.render text: @text
  end
end

class RunPhlex < Phlex::HTML
  def initialize text = "Benchmark"
    @text = text
  end

  def view_template
    div do
      h1 { @text }
    end
  end
end

class RunHtmlSlice
  include HtmlSlice

  def initialize text = "Benchmark"
    @text = text
  end

  def call
    html_slice do
      div do
        h1 @text
      end
    end
  end
end

ITERATIONS = 100_000

Benchmark.bm do |x|
  x.report("erubi") do
    ITERATIONS.times { |count| RunErubi.new("Benchmark #{count}").call }
  end

  x.report("markaby") do
    ITERATIONS.times { |count| RunMarkaby.new("Benchmark #{count}").call }
  end

  x.report("papercraft") do
    ITERATIONS.times { |count| RunPapercraft.new("Benchmark #{count}").call }
  end

  x.report("phlex") do
    ITERATIONS.times { |count| RunPhlex.new("Benchmark #{count}").call }
  end

  x.report("html_slice") do
    ITERATIONS.times { |count| RunHtmlSlice.new("Benchmark #{count}").call }
  end
end

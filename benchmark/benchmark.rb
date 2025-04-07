# frozen_string_literal: true

require "benchmark"
require "byebug"
require "erubi"
require "haml"
require "slim"
require "markaby"
require "papercraft"
require "papercraft/version"
require "phlex"
require "phlex/version"
require "html_slice"

require_relative "context"

CALLS_NUMBER = 100
TAGS_NUMBER = 5000

class RunErubi
  template_code = "<div><h1><%= text %></h1></div>"
  @@context = Context.new
  @@context.instance_eval %{
    def run_erubi; #{Erubi::Engine.new(template_code).src}; end
  }

  def initialize text = "Benchmark"
    @text = text
  end

  def call
    @@context.text = @text
    @@context.run_erubi
  end
end

class RunHaml
  template_code = <<~EOL
    %div
      %h1
        = text
  EOL
  @@context = Context.new
  @@context.instance_eval %{
    def run_haml; #{Haml::Engine.new.call(template_code)}; end
  }

  def initialize text = "Benchmark"
    @text = text
  end

  def call
    @@context.text = @text
    @@context.run_haml
  end
end

class RunSlim
  template_code = <<~EOL
    h1 = text
  EOL
  @@context = Context.new
  @@context.instance_eval %{
    def run_slim; #{Slim::Engine.new.call(template_code)}; end
  }

  def initialize text = "Benchmark"
    @text = text
  end

  def call
    @@context.text = @text
    @@context.run_slim
  end
end

class RunMarkaby
  def initialize text = "Benchmark"
    @text = text
  end

  def call
    Markaby::Builder.new text: @text do
      div do
        (0..TAGS_NUMBER).each do |i|
          h1 @text, style: 'a', id: i, class: 'c', role: 'd'
        end
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
        (0..TAGS_NUMBER).each do |i|
          h1 text, style: 'a', id: i, class: 'c', role: 'd'
        end
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
      (0..TAGS_NUMBER).each do |i|
        h1(style: 'a', id: i, class: 'c', role: 'd') { @text }
      end
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
        (0..TAGS_NUMBER).each do |i|
          h1 @text, style: 'a', id: i, class: 'c', role: 'd'
        end
      end
    end
  end
end

Benchmark.bm do |x|
  x.report("erubi v#{Erubi::VERSION}") do
    CALLS_NUMBER.times { |count| RunErubi.new("Benchmark #{count}").call }
  end

  x.report("haml v#{Haml::VERSION}") do
    CALLS_NUMBER.times { |count| RunHaml.new("Benchmark #{count}").call }
  end

  x.report("slim v#{Slim::VERSION}") do
    CALLS_NUMBER.times { |count| RunSlim.new("Benchmark #{count}").call }
  end

  x.report("markaby v#{Markaby::VERSION}") do
    CALLS_NUMBER.times { |count| RunMarkaby.new("Benchmark #{count}").call }
  end

  x.report("html_slice v#{HtmlSlice::VERSION}") do
    CALLS_NUMBER.times { |count| RunHtmlSlice.new("Benchmark #{count}").call }
  end

  x.report("papercraft v#{Papercraft::VERSION}") do
    CALLS_NUMBER.times { |count| RunPapercraft.new("Benchmark #{count}").call }
  end

  x.report("phlex v#{Phlex::VERSION}") do
    CALLS_NUMBER.times { |count| RunPhlex.new("Benchmark #{count}").call }
  end
end

# frozen_string_literal: true

require "memory_profiler"
require "byebug"
require "markaby"
require "papercraft"
require "papercraft/version"
require "phlex"
require "phlex/version"
#require "html_slice"
require_relative "../lib/html_slice"

require_relative "context"

CALLS_NUMBER = 100
TAGS_NUMBER = 5000

class RunMarkaby
  def initialize text = "Benchmark"
    @text = text
  end

  def call
    Markaby::Builder.new text: @text do
      div do
        (0..TAGS_NUMBER).each do |i|
          h1 @text, style: "a#{i}", id: i, class: 'c', role: 'd', data_class: 'something'
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
    Papercraft.html do
      div do
        (0..TAGS_NUMBER).each do |i|
          h1 @text, style: "a#{i}", id: i, class: 'c', role: 'd', data_class: 'something'
        end
      end
    end
  end
end

class RunPhlex < Phlex::HTML
  def initialize text = "Benchmark"
    @text = text
  end

  def view_template
    div do
      (0..TAGS_NUMBER).each do |i|
        h1(style: "a#{i}", id: i, class: 'c', role: 'd', data_class: 'something') { @text }
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
          h1 @text, style: "a#{i}", id: i, class: 'c', role: 'd', data_class: 'something'
        end
      end
    end
  end
end

p "phlex v#{Phlex::VERSION}"
report = MemoryProfiler.report do
  CALLS_NUMBER.times { |count| RunPhlex.new("Benchmark #{count}").call }
end
report.pretty_print

p "html_slice v#{HtmlSlice::VERSION}"
report = MemoryProfiler.report do
  CALLS_NUMBER.times { |count| RunHtmlSlice.new("Benchmark #{count}").call }
end
report.pretty_print

p "html_slice (singleton) v#{HtmlSlice::VERSION}"
class RunHtmlSlice
  include HtmlSlice

  def call
    CALLS_NUMBER.times { |count|
      html_slice do
        div do
          (0..TAGS_NUMBER).each do |i|
            h1 count, style: "a#{i}", id: i, class: 'c', role: 'd', data_class: 'something'
          end
        end
      end
    }
  end
end
report = MemoryProfiler.report do
  RunHtmlSlice.new.call
end
report.pretty_print

"papercraft v#{Papercraft::VERSION}"
report = MemoryProfiler.report do
  CALLS_NUMBER.times { |count| RunPapercraft.new("Benchmark #{count}").call }
end
report.pretty_print

p "markaby v#{Markaby::VERSION}"
report = MemoryProfiler.report do
  CALLS_NUMBER.times { |count| RunMarkaby.new("Benchmark #{count}").call }
end
report.pretty_print

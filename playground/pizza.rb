# frozen_string_literal: true

require_relative "../lib/html_slice"
require_relative "../lib/html_slice/rails"

class Html
  include HtmlSlice

  def pizza
    html_slice do
      ["🍕","🍕","🍕"].each do |pizza|
        eat(pizza)
      end
    end
  end

  def eat(pizza)
    div class: 'mouth' do
      span "eating: #{pizza}"
    end
  end
end

# Contained version
HtmlSlice.slice do
  h1 "hey"
end

puts(Html.new.pizza)

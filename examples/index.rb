require 'html_slice'

class BaseController
  include HtmlSlice

  def layout
    html_layout do
      tag :head do
        meta charset: 'utf-8'

        custom_head
      end

      tag :body do
        yield
      end
    end
  end
end

class MyController < BaseController
  def render
    layout do
      h1 'hello world'

      div class: 'to-do' do
        to_do_list
      end
    end
  end

  def custom_head
    title 'Hello HtmlSlice'
  end

  private

  def to_do_list
    ul do
      items.each do |item|
        li item
      end
    end
  end

  def items
    ['Clean the house', 'Study Ruby', 'Play sports']
  end
end

p MyController.new.render

class HelloController < ApplicationController
  def h_slice
    render html: (layout do
      h1 "Hello#h_slice"
      tag :p, "Find me in app/controllers/hello_controller.rb"
    end)
  end

  def title
    "Hello"
  end

  def erb
  end
end

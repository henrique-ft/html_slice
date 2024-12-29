![HtmlSlice](https://raw.githubusercontent.com/henrique-ft/html_slice/main/html_slice_logo.png)

# HtmlSlice

Enable Ruby classes the ability to generate reusable pieces of html

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add html_slice

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install html_slice

## Usage

```ruby
require 'html_slice'

class MyHtmlPage
  include HtmlSlice

  def render
    html_slice do
       h1 'hello world'
       text
    end
  end

  def text
    tag :p, %q(
      Lorem ipsum dolor sit amet
    )
  end
end

MyHtmlPage.new.render
```

#### Rails controller example
```ruby
require 'html_slice'

class ApplicationController
  include HtmlSlice

  def html(&block) = html_slice(&block)
end

# Imagine a Rails controller
class MyController < ApplicationController
  before_action :set_items

  def index
    render html: (html do
      h1 'hello world'

      div class: 'to-do' do
        to_do_list
      end
    end)
  end
  # "<h1>hello world</h1><div class='to-do'><ul><li>Clean the house</li><li>Study Ruby</li><li>Play sports</li></ul></div>"

  private

  def to_do_list
    ul do
      @items.each do |item|
        li item
      end
    end
  end

  def set_items
    @items ||= ['Clean the house', 'Study Ruby', 'Play sports']
  end
end
```

##### With layout
```ruby
require 'html_slice'

class ApplicationController
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

# Imagine a Rails controller
class MyController < ApplicationController
  before_action :set_items

  def index
    render html: (layout do
      h1 'hello world'

      div class: 'to-do' do
        to_do_list
      end
    end)
  end
  # "<!DOCTYPE html><html><head><meta charset='utf-8'/><title>Hello HtmlSlice</title></head><body><h1>hello world</h1><div class='to-do'><ul><li>Clean the house</li><li>Study Ruby</li><li>Play sports</li></ul></div></body></html>"

  def custom_head
    title 'Hello HtmlSlice'
  end

  private

  def to_do_list
    ul do
      @items.each do |item|
        li item
      end
    end
  end

  def set_items
    @items ||= ['Clean the house', 'Study Ruby', 'Play sports']
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/henrique-ft/html_slice. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/henrique-ft/html_slice/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the HtmlSlice project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/henrique-ft/html_slice/blob/master/CODE_OF_CONDUCT.md).

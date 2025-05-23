![HtmlSlice](https://raw.githubusercontent.com/henrique-ft/html_slice/main/html_slice_logo.png)

![Gem Version](https://img.shields.io/gem/v/html_slice?style=social)

# HtmlSlice

Enable Ruby classes the ability to generate reusable pieces of html

```ruby
class MyController < ApplicationController
  include HtmlSlice

  def index
    html_slice :say_hello do
      h1 "hello #{pizza}"
    end
  end

  def pizza
    "🍕"
  end
end

# index.html.erb

<%= raw @html_slice[:say_hello] %>
```

## Features

- Generate HTML dynamically in instance scope: unlike Markaby, HtmlSlice `self` points to the class instance that are using it, make easier to reuse code and make abstractions (see https://github.com/markaby/markaby?tab=readme-ov-file#label-A+Note+About+instance_eval).
- HtmlSlice uses `include` instead of inheritance. This means we can "plug" it in anywhere—Rails controllers, services, Sinatra apps, Roda apps—or create specific view classes if needed.
- Can be used to generate all application html or only html partials (slices 🍕).
- Lightweight, use HtmlSlice without performance penalties.
- Escapes HTML content to prevent XSS vulnerabilities.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add html_slice

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install html_slice

## Usage

Include HtmlSlice in any Ruby class to generate HTML dynamically.

```ruby
require 'html_slice'

class HelloView
  include HtmlSlice

  def to_html
    html_slice do
      h1 'hello world'
      text
      div do
        _ '<b> some raw html </b>'
      end
    end
  end

  def text
    tag :p, %q(
      Lorem ipsum dolor sit amet
    )
  end
end

puts HelloView.new.to_html
# <h1>hello world</h1><p>Lorem ipsum dolor sit amet</p><div><b> some raw html </b></div>
```

##### Explanation
- The `html_slice` method starts the HTML generation process creating an **@html_slice** instance variable and returning its content.
- Each time we call the html tag methods, the method append the generated html in **@html_slice**.
- Tags like div, h1, and ul are dynamically defined as methods, enabling you to structure HTML seamlessly.
- Tags that are not defined as methods can be generated using the `tag` method (*only the most common tags are dinamically defined as methods, except "p", "head" and "body")
- Use the `_` method to append raw content to the **@html_slice**.

### Adding Attributes
HTML attributes can be added to tags as a hash:

```ruby
div id: "main", class: "highlighted" do
  span "Hello world"
end
```

"_" in html attributes is converted to "-"
```ruby
div x_data: "{ hello: 'world' }" do # x-data="{ hello: 'world' }"
  span "Hello world"
end
```

### The @html_slice instance variable

The **@html_slice** holds a hash where every key maps to a html string generated calling the "tag methods", html slice default key is `:default`

```ruby
require 'html_slice'

class HelloView
  include HtmlSlice

  def to_html
    html_slice do # @html_slice[:default] = ''
      h1 'hello world' # @html_slice[:default] << '<h1>hello world</h1>'
      text # @html_slice[:default] << '<p>Lorem ipsum dolor sit amet</p>'
      div do
        _ '<b> some raw html </b>'
      end
    end

    html_slice :some_key do # @html_slice[:some_key] = ''
      h1 'hello world' # @html_slice[:some_key] << '<h1>hello world</h1>'
      text # @html_slice[:some_key] << '<p>Lorem ipsum dolor sit amet</p>'
      div do
        _ '<b> some raw html </b>'
      end
    end
  end

  def text
    tag :p, %q(
      Lorem ipsum dolor sit amet
    )
  end
end

HelloView.new.to_html
```

⚠️ Important: Tag methods and our instance methods that use the tag methods must only be called inside an `html_slice` block

### Roda example

```ruby
class App < Roda                           
  include HtmlSlice                        
                                           
  def layout                               
    html_layout do                         
      yield                                
    end                                    
  end                                      
                                             
  plugin :autoload_hash_branches           
  autoload_hash_branch_dir('./app/routes') 
                                           
  route(&:hash_branches)                   
end     

# app/routes/foods

class App                              
  hash_branch('foods') do |r|          
    r.is do                            
      r.get do                         
        @foods = Food.order(:name).all 
                                       
        layout do                      
          ul do                        
            @foods.each do |food|      
              li food.inspect          
            end                        
          end                          
        end                            
      end                              
    end                                
  end                                  
end                                    

```                                   

### Rails examples

##### Rendering pure html slices:
```ruby
class ApplicationController
  include HtmlSlice

  def html(&block)
    html_slice(&block).html_safe
  end
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
##### Rendering partials using html slice keys:

```ruby
class MyController < ApplicationController
  include HtmlSlice

  def index
    html_slice :say_hello do
      h1 "hello #{pizza}"
    end
  end

  def pizza
    "🍕"
  end
end

# index.html.erb

<%= raw @html_slice[:say_hello] %>
```

##### Rendering entire html pages with `html_layout`:
```ruby
class ApplicationController
  include HtmlSlice

  def layout
    html_layout { # Same as html_slice but wrap the content in a <!DOCTYPE html><html>...</html> structure
      tag :head do
        meta charset: 'utf-8'

        custom_head
      end

      tag :body do
        yield
      end
    }.html_safe
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

##### Using Rails view helpers

We must use the `_` method that render raw content

```ruby
class HelloController < ApplicationController
  def index
    render html: (html do
      h1 'Hello#h_slice'
      tag :p, 'Find me in app/controllers/hello_controller.rb'

      _ helpers.link_to('oi')

      _ (helpers.form_for 'user' do |f|
        f.text_field('name')
      end)
    end)
  end
end

```

## Benchmarks

Rendering 5000 `h1` with attributes 100 times (cpu time):
```
                   user       system     total    real
phlex v1.11.0      0.815566   0.020756   0.836322 (0.836379)
html_slice v0.2.2  2.577327   0.014989   2.592316 (2.592524)
papercraft v1.4    2.702237   0.013971   2.716208 (2.716460)
markaby v0.9.4    27.611695   0.050988  27.662683 (27.664897)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/henrique-ft/html_slice. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/henrique-ft/html_slice/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the HtmlSlice project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/henrique-ft/html_slice/blob/master/CODE_OF_CONDUCT.md).

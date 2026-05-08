![HtmlSlice](https://raw.githubusercontent.com/henrique-ft/html_slice/main/html_slice_logo.png)

![Gem Version](https://img.shields.io/gem/v/html_slice?style=social)

# HtmlSlice

Generate reusable HTML with pure Ruby, in any context, without performance penalties.

Using `include`:
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

Or generating with the `slice` class method:
```ruby
HtmlSlice.slice :pizza do
  h1 "🍕"
end

puts HtmlSlice.slice :pizza # <h1>"🍕"</h1>
```

## Features

- Lightweight, use **HtmlSlice** without performance penalties (see [#benchmarks](#benchmarks)). It's just a single Ruby file.
- When included, generate HTML dynamically in instance scope: unlike Markaby, HtmlSlice `self` points to the class instance that are using it, make easier to reuse code and make abstractions (see https://github.com/markaby/markaby?tab=readme-ov-file#label-A+Note+About+instance_eval).
- Unlike Phlex, HtmlSlice uses `include` instead of inheritance. This means we can "plug" it in anywhere—scripts, Rails controllers, services, Sinatra apps, Roda apps—or create specific view classes if needed.
- Can be used to generate all application html or only html partials (slices 🍕).
- Escapes HTML content to prevent XSS vulnerabilities.
- Can be used anywhere without friction, using the `HtmlSlice.slice` class method. Useful to avoid name pollution in specific contexts.


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

Using the `.slice` class method (without including HtmlSlice), the flow is the same, but **@html_slice** is encapsulated and no longer exposed directly.

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
          ul {                        
            @foods.each do |food|      
              li food.inspect          
            end                        
          }                          
        end                            
      end                              
    end                                
  end                                  
end                                    

```                                   

### Rails usage

Add this line in **config/application.rb**:
```ruby
config.eager_load_paths << Rails.root.join("app", "views")
```

Add the slices method in **app/helpers/application_helper.rb**:
```ruby
module ApplicationHelper          
  def slices = @slices ||= ::Slices.new 
end                               
```

Create your slices in **app/views/slices.rb**:
```ruby
class Slices                                     
  include HtmlSlice::Rails                     
                                               
  def user_list(users)                         
    slice do                                   
      users.each do |user|                     
        div id: dom_id(user) {                 
          div {                                
            strong 'Name:'                     
            _(user.name)                       
          }                                    
                                               
          div {                                
            strong 'Age:'                      
            _(user.age)                        
          }                                    
                                               
          _(link_to "New user", new_user_path) 
        }                                      
      end                                      
    end                                        
  end                                          
end                                            
```

Enjoy:

```erb
<div id="users">                 
  <%# @users.each do |user| %>   
    <%#= render user %>          
  <%# end %>                     
                                 
  <!-- 20% faster -->            
  <%= slices.user_list(@users) %>  
</div>                           
```

#### Scaling

```
▢ views/                 
  ▢ layouts/             
  ▢ pwa/                 
  ▢ slices/              
      users.rb <- Slices::Users
  ▢ users/       
      edit.html.erb      
      index.html.erb     
      new.html.erb       
      show.html.erb      
    slices.rb              
```

```ruby
class Slices                                     
  attr_reader :users
  
  def initialize
    @users = Slices::Users.new
  end
end                                            
```

```ruby
class Slices                                    
  class Users                                   
    include HtmlSlice::Rails                    
                                                
    def list(users)                             
      slice do                                  
        users.each do |user|                    
          div(id: dom_id(user)) {               
            div {                               
              strong 'Name:'                    
              _(user.name)                      
            }                                   
                                                
            div {                               
              strong 'Age:'                     
              _(user.age)                       
            }                                   
                                                
            _(link_to "New user", new_user_path)
          }                                     
        end                                     
      end                                       
    end                                         
  end                                           
end                                                                                        
```
```erb
<div id="users">                 
  <%# @users.each do |user| %>   
    <%#= render user %>          
  <%# end %>                     
                                 
  <!-- 20% faster -->            
  <%= slices.users.list(@users) %>  
</div>                           
```


## Benchmarks

Ruby `v3.4.0`

### CPU Time

Rendering 500 `<h1>` with attributes 1000 times:

less is better
```
                       user     system      total        real
html_slice v0.2.6  1.662246   0.002968   1.665214 (  1.665281)
phlex v2.4.1       7.795550   0.009967   7.805517 (  7.806166)
papercraft v3.2.1  6.186218   0.042994   6.229212 (  6.229857)
```

### Memory usage

Rendering 200 `<h1>` with attributes 200 times:

less is better
```
 html_slice v0.2.6:   35MB allocated
      phlex v2.4.1:   63MB allocated - 1.78x more
 papercraft v3.2.1:   97MB allocated - 2.71x more
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/henrique-ft/html_slice. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/henrique-ft/html_slice/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the HtmlSlice project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/henrique-ft/html_slice/blob/master/CODE_OF_CONDUCT.md).

# Banana

[![Gem Version](https://badge.fury.io/rb/banana.svg)](https://badge.fury.io/rb/banana)
[![Build Status](https://secure.travis-ci.org/sinsoku/banana.png?branch=master)](http://travis-ci.org/sinsoku/banana)

A simple plugin for multiple databases in rails app.

## Installation

Add this line to your application's Gemfile:

    gem 'banana'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install banana

## Usage

1. add multiple database settings to `config/database.yml`
2. add connection setting to model
3. add database name to migration
4. as always run `rake db:create`, `rake db:migrate`, `rake db:drop`

## Examples

```yaml
# config/database.yml
default: &default
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  username: root
  password:
  socket: /var/run/mysqld/mysqld.sock

development:
  <<: *default
  database: fruit_development

test:
  <<: *default
  database: fruit_test

production:
  <<: *default
  database: fruit_production

vegetable_development:
  <<: *default
  database: vegetable_development

vegetable_test:
  <<: *default
  database: vegetable_test

vegetable_production:
  <<: *default
  database: vegetable_production
```


```ruby
# app/models/vegetable.rb
class Vegetable < ActiveRecord::Base
  establish_connection "vegetable_#{Rails.env}"
end
```
```ruby
# app/models/onion.rb
class Onion < Vegetable
end
```

```ruby
# db/migrate/20120728121720_create_onions.rb
class CreateOnions < ActiveRecord::Migration
  DATABASE_NAME = "vegetable_#{Rails.env}"

  def change
    create_table :onions do |t|

      t.timestamps
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

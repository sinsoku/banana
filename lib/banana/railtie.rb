require 'rails/railtie'

module Banana
  class Railtie < Rails::Railtie
    rake_tasks do
      load "banana/tasks/database.rake"
    end
  end
end

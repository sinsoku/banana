tasks = Rake.application.instance_variable_get '@tasks'
override_tasks = ['db:create', 'db:drop', 'db:migrate', 'db:schema:dump']
override_tasks.each { |task_name| tasks.delete(task_name) }

db_namespace = namespace :db do
  desc 'Create the multiple databases from config/database.yml for the current Rails.env (use db:create:all to create all dbs in the config)'
  task :create => :load_config do
    configs_for_multi_environment.each do |config|
      if Gem::Version.new(Rails.version) < Gem::Version.new('4.0.0')
        create_database(config)
      else
        ActiveRecord::Tasks::DatabaseTasks.create config
      end
    end
  end

  desc "Migrate the database (options: VERSION=x, VERBOSE=false)."
  task :migrate => [:environment, :load_config] do
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)

    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
    db_namespace['_dump'].invoke
  end

  desc 'Drops the multiple databases for the current Rails.env (use db:drop:all to drop all databases)'
  task :drop => :load_config do
    configs_for_multi_environment.each do |config|
      if Gem::Version.new(Rails.version) < Gem::Version.new('4.0.0')
        drop_database_and_rescue(config)
      else
        ActiveRecord::Tasks::DatabaseTasks.drop config
      end
    end
  end

  namespace :schema do
    desc 'Create a db/schema.rb file that can be portably used against any DB supported by AR'
    task :dump => [:environment, :load_config] do
      require 'banana/multidb_schema_dumper'
      filename = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"
      File.open(filename, "w:utf-8") do |file|
        environments = ActiveRecord::Base.configurations.keys.select { |x| x =~ /#{Rails.env}$/ }.map(&:to_sym)
        Banana::MultidbSchemaDumper.dump_multidb(environments, file)
      end
      db_namespace['schema:dump'].reenable
    end
  end
end

def configs_for_multi_environment
  environments = ActiveRecord::Base.configurations.keys.select { |x| x =~ /#{Rails.env}$/ }
  environments += ActiveRecord::Base.configurations.keys.select { |x| x =~ /test$/ } unless Rails.env.production?
  ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['database'].blank? }
end

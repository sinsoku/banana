tasks = Rake.application.instance_variable_get '@tasks'
tasks.delete 'db:create'
tasks.delete 'db:drop'
tasks.delete 'db:schema:dump'

db_namespace = namespace :db do
  desc 'Create the multiple databases from config/database.yml for the current Rails.env (use db:create:all to create all dbs in the config)'
  task :create => :load_config do
    configs_for_multi_environment.each { |config| create_database(config) }
  end

  desc 'Drops the multiple databases for the current Rails.env (use db:drop:all to drop all databases)'
  task :drop => :load_config do
    configs_for_multi_environment.each { |config| drop_database_and_rescue(config) }
  end

  namespace :schema do
    desc 'Create a db/schema.rb file that can be portably used against any DB supported by AR'
    task :dump => [:environment, :load_config] do
      require 'banana/multidb_schema_dumper'
      filename = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"
      File.open(filename, "w:utf-8") do |file|
        environments = ActiveRecord::Base.configurations.keys.select { |x| x =~ /#{Rails.env}$/ }
        Banana::MultidbSchemaDumper.dump_multidb(environments, file)
      end
      db_namespace['schema:dump'].reenable
    end
  end
end

def configs_for_multi_environment
  environments = ActiveRecord::Base.configurations.keys.select { |x| x =~ /#{Rails.env}$/ }
  environments += ActiveRecord::Base.configurations.keys.select { |x| x =~ /test$/ } if Rails.env.development?
  ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['database'].blank? }
end

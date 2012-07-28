require 'active_record'

module ActiveRecord
  class Migration
    def migrate_with_multidb(direction)
      if defined? self.class::DATABASE_NAME
        ActiveRecord::Base.establish_connection(self.class::DATABASE_NAME)
        migrate_without_multidb(direction)
        ActiveRecord::Base.establish_connection(Rails.env)
      else
        migrate_without_multidb(direction)
      end
    end
    alias_method_chain :migrate, :multidb
  end
end

require 'active_record'

module Banana
  class MultidbSchemaDumper < ActiveRecord::SchemaDumper
    public :header, :tables, :trailer

    def self.dump_multidb(specs=[], stream=STDOUT)
      specs.each_with_index do |spec, index|
        ActiveRecord::Base.establish_connection(spec)
        dumper = new(ActiveRecord::Base.connection)
        dumper.header(stream) if index == 0
        dumper.tables(stream)
        dumper.trailer(stream) if index == specs.count - 1
      end
      stream
    end
  end
end

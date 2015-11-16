require 'spec_helper'

describe Banana do
  describe '::VERSION' do
    it 'has a version number' do
      expect(Banana::VERSION).not_to be nil
    end
  end
end

require 'spec_helper'

describe 'Core extensions' do

  describe 'Adding new methods for Hash items' do

    describe 'defining underscore_keys' do

      context 'from simple plain hash' do

        it 'underscores each key' do
          { 'foo-bar' => 42, foo: 42, 'foo' => 42 }.underscore_keys.should == { 'foo_bar' => 42, foo: 42, 'foo' => 42 }
        end

      end

      context 'from nested hashes' do

        it 'underscores each key' do
          { 'foo-bar' => { 'bar-foo' => 42, test: { 'bar-foo' => 42 } } }.underscore_keys.should == { 'foo_bar' => { 'bar_foo' => 42, test: { 'bar_foo' => 42 } } }
        end

      end

      context 'from hash with arrays of hashes' do

        it 'underscores each key' do
          { 'foo-bar' => [{ 'bar-foo' => 42 }, 42, { 'bar-foo' => 42 }] }.underscore_keys.should == { 'foo_bar' => [{ 'bar_foo' => 42 }, 42, { 'bar_foo' => 42 }] }
        end

      end

    end

  end

end

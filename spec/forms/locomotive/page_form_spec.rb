require 'spec_helper'

module Locomotive
  describe PageForm do

    describe '#target_klass_name=' do
      subject { PageForm.new(target_klass_name: 'foobar') }
      it 'should set target_klass_slug' do
        expect(subject.target_klass_slug).to eq('foobar')
      end
    end

    describe '#target_entry_name=' do
      subject { PageForm.new(target_entry_name: 'foobar') }
      it 'should set target_klass_slug' do
        expect(subject.target_klass_slug).to eq('foobar')
      end
    end

  end
end

require 'rails_helper'

# Invariant: a Mongo ObjectId serializes to a plain id string in JSON (API
# responses, jbuilder), never to BSON extended JSON ({ "$oid" => ... }).
describe BSON::ObjectId do

  let(:oid) { described_class.from_string('5f1e2d3c4b5a6978899a0b1c') }

  it 'serializes as_json to the plain id string' do
    expect(oid.as_json).to eq('5f1e2d3c4b5a6978899a0b1c')
  end

  it 'serializes to_json to the quoted id string' do
    expect(oid.to_json).to eq('"5f1e2d3c4b5a6978899a0b1c"')
  end

end

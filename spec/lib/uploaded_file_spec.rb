require 'spec_helper'

describe ActionDispatch::Http::UploadedFile do

  it 'correctly converts the uploaded file into a liquid object' do
    file = File.open(Rails.root + 'spec/tmp/test_pdf.pdf', 'w')
    uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: File.basename(file), type: "application/pdf")
    liquid_object = uploaded_file.to_liquid
    liquid_object['original_filename'].should == File.basename(file)
    liquid_object['content_type'].should == 'application/pdf'
    liquid_object['tempfile'].should == file
  end

end
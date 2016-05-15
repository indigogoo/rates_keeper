require 'rails_helper'
require 'rake'

describe 'rates:import' do

  before { RatesKeeper::Application.load_tasks }

  after(:all) do
    FileUtils.rm_rf(File.join(Rails.root, 'tmp', 'rates', 'test'))
    Rate.destroy_all
  end

  let(:response_test_file_path) { File.join(Rails.root, 'spec', 'files', "test_response_european_central_bank.csv") }

  it 'should successfully import the data from remote host' do
    stub_request(:get, "http://sdw.ecb.europa.eu/export.do?CURRENCY=USD&FREQ=D&node=2018794&q=%7B:%22submitOptions.y%22=%3E6,%20:%22submitOptions.x%22=%3E51,%20:sfl1=%3E4,%20:end=%3E%22%22,%20:SERIES_KEY=%3E%22120.EXR.D.USD.EUR.SP00.A%22,%20:sfl3=%3E4,%20:DATASET=%3E0,%20:exportType=%3E%22csv%22%7D&start=start&trans=N&type=").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'sdw.ecb.europa.eu', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: File.new(response_test_file_path))
    expect { Rake::Task['rates:import'].invoke }.not_to raise_exception
  end

  let(:rates_dir) { File.join(Rails.root, 'tmp', 'rates') }
  let(:rates_test_dir) { File.join(rates_dir, 'test') }
  let(:new_rates_file_path) { File.join(rates_test_dir, "european_central_bank_rates.csv") }
  let(:log_file_path) { File.join(rates_test_dir, "importer.log") }
  let(:valid_lines_count) { 8 }

  it 'should create a csv file with fetched data' do 
    expect(File.exist?(new_rates_file_path)).to be_truthy
  end

  it 'should create a csv file with the same content as returned in response' do
    expect(FileUtils.compare_file(response_test_file_path, new_rates_file_path)).to be_truthy
  end

  it 'should create logfile for import' do
    expect(File.exist?(log_file_path)).to be_truthy
  end

  it 'should import only valid rates' do
    expect( Rate.count ).to eq(valid_lines_count)
  end
end

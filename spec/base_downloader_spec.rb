require 'spec_helper'

class TestDownloader < GoodData::Connectors::Downloader::BaseDownloader
  attr_reader :random_value

  def initialize(metadata, params)
    @type = "test"
    @format = "csv"
    super(metadata, params)
    @random_value = rand(1234).to_s
  end

  def get_field_metadata
    {
      "Bike" => {
        "fields" => [
          {
            "name" => "wheel_size",
            "type" => "double",
            "human_name" => "Wheel Size"
          },
          {
            "name" => "manufacturer",
            "type" => "string",
            "human_name" => "Manufacturer"
          }
        ]
      },
      "Surfboard" => {
        "fields" => [
          {
            "name" => "length",
            "type" => "double",
            "human_name" => "Length"
          }
        ]
      }
    }
  end

  def sample_data
    {
      "Bike" => [
        ["29", "Specialized"],
        ["27.5", "Scott"],
        ["29", "Scott"],
        [@random_value, @random_value]
      ],
      "Surfboard" => [
        ["6.6"],
        ["7.5"],
        [@random_value]
      ]
    }
  end

  def download(entity_metadata)
    ret = {}
    entity_metadata.each do |entity, v|
      filename = generate_filename(entity)
      CSV.open(filename, 'w', :force_quotes => true) do |csv|
        # write the headers
        csv << v['fields'].map{|f| f['name']}

        # put some data there
        sample_data[entity].each do |row|
          csv << row
        end
      end
      ret[entity] = {'filenames' => [filename]}
    end
    return {'objects' => ret}
  end
end

describe GoodData::Connectors::Downloader::BaseDownloader do
  describe 'backup' do
    context 'when given random files' do
      it 'backs it up' do
        # create a downloader that backs up
        downloader = TestDownloader.new(nil, {
          'config' => {
            'downloader' => {
              'test' => {
                'aws_access_key_id' => ENV['aws_access_key_id'],
                'aws_secret_access_key' => ENV['aws_secret_access_key'],
                's3_backup_bucket_name' => ENV['s3_backup_bucket_name'],
              },
              'data_directory' => "test_downloads"
            }
          }
        })
        downloader.run

        # it should be there
        s3 = AWS::S3.new(
          :access_key_id => ENV['aws_access_key_id'],
          :secret_access_key => ENV['aws_secret_access_key']
        )
        bucket = s3.buckets[ENV['s3_backup_bucket_name']]
        test_files = bucket.objects.with_prefix('test_downloads/Bike').collect(&:key)

        # take the latest test_downloads/Bike* file
        latest = test_files.sort[-1]
        latest_contents = bucket.objects[latest].read

        # the random value should be there
        latest_contents.should include(downloader.random_value)
      end
    end
  end
end

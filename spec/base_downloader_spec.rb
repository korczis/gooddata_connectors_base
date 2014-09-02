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

      # make an empty file just for fun
      f2 = generate_filename(entity)
      FileUtils.touch(f2)

      ret[entity] = {'filenames' => [filename, f2]}
    end
    return {'objects' => ret}
  end

  def is_file_empty(filename)
    return File.size(filename) == 0
  end

end

describe GoodData::Connectors::Downloader::BaseDownloader do
  describe 'backup' do
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

  describe "clean_up" do
    it "doesn't let empty files out" do
      downloader = TestDownloader.new(nil, {
        'config' => {
          'downloader' => {
            'test' => {
              'skip_backup' => true
            },
            'data_directory' => 'test_downloads'
          }
        }
      })

      data = downloader.run

      # there should be one non-empty files for each entity
      data["objects"].each do |k, v|
        v["filenames"].length.should be(1)
        File.size(v['filenames'][0]).should be > 0
      end
    end

    it "keeps empty files there if skip_cleanup given" do
      downloader = TestDownloader.new(nil, {
        'config' => {
          'downloader' => {
            'test' => {
              'skip_backup' => true,
              'skip_cleanup' => true
            },
            'data_directory' => 'test_downloads'
          }
        }
      })

      data = downloader.run

      # there should be one empty and one non-empty file
      data["objects"].each do |k, v|
        v["filenames"].length.should be(2)
      end
    end
  end
end

module GoodData
  module Connectors
    module Downloader
      class BaseDownloader

        attr_accessor :metadata,:configuration

        def initialize(metadata, params)
          @metadata = metadata
          @global_params = params
          @downloader_params = @global_params['config']['downloader']
          if ! @type
            raise "You must define @type in your downloader e.g. 'salesforce'"
          end
          @params = @downloader_params[@type]
          @data_directory ||= @downloader_params['data_directory'] || 'downloads'
          @format ||= 'txt'
          @api_version = @params['api_version'] || @default_api_version
          @logger = @global_params['GDC_LOGGER'] || Logger.new(STDOUT)
          prepare_folders()
        end

        def backup(meta)
          @logger.info 'send a backup list of files to backup'
          files = meta['objects'].values.reduce([]){|memo, v| memo + v['filenames']}

          bucket_name = @params['s3_backup_bucket_name']

          s3 = AWS::S3.new(
            :access_key_id => @params['aws_access_key_id'],
            :secret_access_key => @params['aws_secret_access_key']
          )

          bucket = s3.buckets[bucket_name]
          bucket = s3.buckets.create(bucket_name) unless bucket.exists?

          files.each do |file|
            obj = bucket.objects[file]
            obj.write(Pathname.new(file))
          end

          meta
        end

        # Run downloader - to be called from outside (as the only method)
        def run
          entity_metadata = get_field_metadata
          downloaded_data = download(entity_metadata)
          # TODO download metadata using a subclass-defined function
          # TODO store metadata
          downloaded_data = clean_up(downloaded_data) unless @params['skip_cleanup']

          downloaded_data = backup(downloaded_data) unless @params['skip_backup']
          return downloaded_data
        end

        def clean_up(downloaded_data)
          # iterate throught the downloaded files and keep onlhy those non-empty
          downloaded_data['objects'].each do |k,v|
            v['filenames'].select! do |f|
              empty = is_file_empty(f)
              FileUtils.rm(f) if empty
              !empty
            end
          end

          return downloaded_data
        end

        def is_file_empty(filename)
          return false
        end

        def get_field_metada
          raise NotImplementedError, "To be defined in subclass"
        end

        def download
          raise NotImplementedError, "To be defined in subclass"
        end

        def generate_filename(obj)
          return File.join(@data_directory, "#{obj}-#{DateTime.now.to_i.to_s}-#{rand(9999).to_s}.#{@format}")
        end

        private

        def prepare_folders
          FileUtils.mkdir_p(@data_directory)
        end
      end
    end
  end
end

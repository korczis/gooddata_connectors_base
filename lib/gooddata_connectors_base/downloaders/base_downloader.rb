module GoodDataConnectorsBase

  class BaseDownloader

  attr_accessor :metadata,:configuration

    def initialize(metadata,options = {})
      @metadata = metadata
      @data_directory = "downloads/"
      @configuration = @metadata.get_configuration_by_type(@TYPE)
      check_mandatory_configuration()
      merge_default_configuration()
      add_entities()
      add_default_entities()
      prepare_folders()
    end

    def define_mandatory_configuration
      {
          "global" => ["bds_bucket","bds_folder","bds_access_key","bds_secret_key"]
      }
    end

    def define_default_configuration
      raise NotImplemented, "The define_default_configuration method need to be implemented"
    end

    def define_default_entities
      raise NotImplemented, "The define_default_entities method need to be implemented"
    end

    # This function will load metadata about entities (fields, field_types,etc)
    def load_entities_metadata()
      raise NotImplemented, "The load_entities_metadata need to be implemented"
    end

    def download_entity(entity)
      raise NotImplemented, "The download_entity need to be implemented"
    end

    def backup_to_bds(metadata_entity)
      bucket = @metadata.get_configuration_by_type("global")["bds_bucket"]
      folder = @metadata.get_configuration_by_type("global")["bds_folder"]
      access_key = @metadata.get_configuration_by_type("global")["bds_access_key"]
      secret_key = @metadata.get_configuration_by_type("global")["bds_secret_key"]
      schedule_id = @metadata.get_configuration_by_type("global")["schedule_id"]
      execution_id = @metadata.get_configuration_by_type("global")["execution_id"]

      # Get an instance of the S3 interface.
      AWS.config({
                     :access_key_id => access_key,
                     :secret_access_key => secret_key
                 })
      s3 = AWS::S3.new
      # Upload a file.
      ## TO DO CHANGE CESTA
      key = File.basename(metadata_entity.get_history_field("downloaded_filename"))
      s3.buckets[bucket].objects["#{folder}/#{schedule_id}/#{execution_id}/#{key}"].write(:file => metadata_entity.get_history_field("downloaded_filename"))
      $log.info "Uploading file #{metadata_entity.get_history_field("downloaded_filename")} to BDS storage."
    end


    private

    def check_mandatory_configuration
      @metadata.check_configuration_mandatory_parameters(define_mandatory_configuration)
    end

    def merge_default_configuration
      @metadata.merge_default_configuration(define_default_configuration)
    end

    def add_default_entities
      @metadata.add_default_entities(define_default_entities)
    end

    def add_entities
      @metadata.add_entities
    end

    def prepare_folders
      FileUtils.mkdir_p(@data_directory)
    end


  end


end

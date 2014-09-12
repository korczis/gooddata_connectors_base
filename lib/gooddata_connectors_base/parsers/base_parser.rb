module GoodData
  module Connectors
    module Base

      class BaseParser

        HISTORY_FILE_STRUCTURE = ["id","key","value","timestamp","is_deleted"]





        attr_accessor :metadata,:templates

        def initialize(metadata,options = {})
          @metadata = metadata
          @data_directory = "source/parser/"
          check_mandatory_configuration()
          merge_default_configuration()
          prepare_folders()
        end

        def define_mandatory_configuration
          {
              "global" => ["bds_bucket","bds_folder","bds_access_key","bds_secret_key"]
          }
        end

        def define_default_configuration

        end

        def parse_entity(entity)
          raise NotImplemented, "The define_default_configuration method need to be implemented"
        end

        private

        def check_mandatory_configuration
          @metadata.check_configuration_mandatory_parameters(define_mandatory_configuration)
        end

        def merge_default_configuration
          @metadata.merge_default_configuration(define_default_configuration)
        end

        def prepare_folders
          FileUtils.mkdir_p(@data_directory)
        end


      end


    end
  end
end

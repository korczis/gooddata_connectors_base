require "erubis"

module GoodData
  module Connectors
    module Base


      class BaseStorage

        HISTORY_TABLE = {
            "id" => "varchar(255)",
            "key" => "varchar(255)",
            "value" => "varchar(255)",
            "timestamp" => "timestamp NOT NULL DEFAULT now()",
            "is_deleted" => "boolean"
        }




        attr_accessor :metadata,:templates

        def initialize(metadata, template_folder, options = {})
          @metadata = metadata
          load_templates(template_folder)
          check_mandatory_configuration()
          merge_default_configuration()
        end


        def load_templates(folder)
          Templates.populate(folder)
        end

        def storage_table_structure
          raise NotImplemented, "The storage_table_structure method need to be implemented"
        end

        def process_entity(entity)
          raise NotImplemented, "The process_entity method need to be implemented"
        end

        def define_mandatory_configuration
          {
              "global" => ["bds_bucket","bds_folder","bds_access_key","bds_secret_key"]
          }
        end

        def define_default_configuration
          raise NotImplemented, "The define_default_configuration method need to be implemented"
        end


        private

        def check_mandatory_configuration
          @metadata.check_configuration_mandatory_parameters(define_mandatory_configuration)
        end

        def merge_default_configuration
          @metadata.merge_default_configuration(define_default_configuration)
        end




      end


    end
  end
end
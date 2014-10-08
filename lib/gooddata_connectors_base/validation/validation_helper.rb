module GoodData
  module Connectors
    module Base
      class ValidationHelper

        class << self

          # @param [Array] folders List of folders where we should look for validations
          # @param [String] type Type of component which requested validation listing
          # @param [Entity] entity Metadata entity
          def generate_validations(folders,type,entity)
            folders.each do |folder|
              list_of_file = Dir["#{folder}/*.erb"]
              @templates = {}
              list_of_file.each do |file|
                key = File.basename(file).split(".").first
                # File name should be in this format type_entity.query_language.erb
                decommission = key.split("_")
                if (decommission.count == 2)
                  if (decommission[1].downcase == entity.id.downcase)
                    validation = Validation.new(entity,type,file)
                    entity.add_validation(decommission[0],type,validation)
                  end
                else
                  validation = Validation.new(entity,type,file)
                  entity.add_validation(decommission[0],type,validation)
                end
              end
            end
          end


        end




      end
    end
  end
end
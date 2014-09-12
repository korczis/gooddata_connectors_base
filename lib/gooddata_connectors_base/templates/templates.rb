module GoodData
  module Connectors
    module Base

      class Templates


        class << self

          def populate(templates_folder)
            list_of_file = Dir["#{templates_folder}/*.erb"]
            @templates = {}
            list_of_file.each do |file|
              key = File.basename(file).split(".").first
              @templates[key] = file
            end
          end

          def make(key,input)
            filename = @templates[key]
            raise TemplateException,"The required template is not present" if (filename.nil?)
            template = File.read(filename)
            template = Erubis::Eruby.new(template)
            template.result(:input => input)
          end


        end

      end
    end
  end
end
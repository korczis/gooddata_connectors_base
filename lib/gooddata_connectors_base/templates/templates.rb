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
            raise TemplateException,"The required template is not present #{key}" if (filename.nil?)
            file = File.read(filename)
            template = Erubis::Eruby.new(file)
            template.result(:input => input)
          end

          def make_validation_template(validation,values)
            raise TemplateException,"The required template is not present #{validation.template}" if (validation.template.nil?)
            file = File.read(validation.template)
            template = Erubis::Eruby.new(file)
            template.result(:input => values)
          end


        end

      end
    end
  end
end
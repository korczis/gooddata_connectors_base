require "gooddata_connectors_base/version"

require "gooddata_connectors_metadata"
require "gooddata"
require 'aws-sdk'

require_relative "gooddata_connectors_base/global"
require_relative "gooddata_connectors_base/downloaders/base_downloader"
require_relative "gooddata_connectors_base/parsers/base_parser"
require_relative "gooddata_connectors_base/storages/base_storage"
%w(downloader_exception not_implemented ads_exception template_exception parse_exception).each {|file| require_relative "gooddata_connectors_base/exceptions/#{file}"}
%w(templates).each {|file| require_relative "gooddata_connectors_base/templates/#{file}"}
#Dir["gooddata_connectors_base/exceptions/*.rb"].each {|file| pp file }




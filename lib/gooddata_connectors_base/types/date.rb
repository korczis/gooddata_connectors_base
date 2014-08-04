module GoodDataConnectorsBase

  class DateType < BaseType


    def initialize(with_time = false)
      super("date",0)
      @with_time = with_time
    end

    def to_hash
      {
          "type" => @type,
          "with_time" => @with_time
      }
    end

    def from_hash(hash)
      if (hash.include?("type"))
        @type = hash["type"]
      else
        raise TypeException, "Some of the mandatory parameter for date type are missing"
      end
      @with_time = hash["with_time"] || false
    end



  end


end
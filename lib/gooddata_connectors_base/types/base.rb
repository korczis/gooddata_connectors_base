module GoodDataConnectorsBase

  class BaseType

    attr_accessor :type,:size


    def initialize(type,size)
      @type = type
      @size = size
    end


    def to_hash
      {
          "type" => @type,
          "size" => @size
      }
    end

    def from_hash(hash)
      if (hash.include?("type"))
        @type = hash["type"]
      else
        raise TypeException,"The hash need to have type value"
      end
      if (hash.include?("size"))
        @size = hash["size"]
      end
    end



  end


end
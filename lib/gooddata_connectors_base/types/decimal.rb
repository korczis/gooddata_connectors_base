module GoodDataConnectorsBase

  class DecimalType < BaseType


    attr_accessor :size_before_comman,:size_after_comma

    def initialize(size,size_after_comma)
      super("decimal",size)
      @size_after_comma = size_after_comma
    end

    def to_hash
      {
          "type" => @type,
          "size_after_comma" => @size_after_comma,
          "size" => @size
      }
    end

    def from_hash(hash)
      if (hash.include?("type") and hash.include?("size_after_comma") and hash.include?("size") )
        @type = hash["type"]
        @size_after_comma = hash["size_after_comma"]
        @size = hash["size"]
      else
        raise TypeException, "Some of the mandatory parameter for decimal type are missing"
      end
    end


  end


end
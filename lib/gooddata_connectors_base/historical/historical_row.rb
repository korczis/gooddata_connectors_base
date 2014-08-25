module GoodDataConnectorsBase

  class HistoricalRow


    attr_accessor :id,:timestamp,:value,:is_deleted

    def initialize(id,timestamp,type,value,is_deleted = false)
      @id = id
      @timestamp  = timestamp
      @value = value
      @type = type
      @is_deleted = is_deleted
    end

    def to_a
      [@id,@timestamp,@type.to_simple_string,@value,@is_deleted]
    end


  end
end
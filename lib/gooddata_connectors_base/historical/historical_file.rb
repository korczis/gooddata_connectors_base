module GoodDataConnectorsBase

  class HistoricalFile



    attr_accessor :historical_rows


    def initialize()
      @historical_rows = []
    end


    def add_row(row)
      @historical_rows << row
    end

    def header
      ["id","timestamp","value","is_deleted"]
    end

    def save_to_file(filename)
      FasterCSV.open(filename, 'w',:quote_char => '"') do |csv|
        csv << header
        @historical_rows.each do |d|
          csv << d.to_a
        end
      end

    end





  end
end
module CebuPacFares
  class Flight
    attr_reader :flight_number
    attr_reader :departure_time
    attr_reader :arrival_time
    attr_reader :from_airport
    attr_reader :to_airport
    attr_reader :duration
    attr_reader :price

    def initialize(options)
      @flight_number = options[:flight_number]
      @departure_time = options[:departure_time]
      @arrival_time = options[:arrival_time]
      @from_airport = options[:from_airport]
      @to_airport = options[:to_airport]
      @duration = options[:duration]
      @price = options[:price]
    end
  end
end

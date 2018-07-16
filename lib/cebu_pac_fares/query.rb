module CebuPacFares
  class Query
    attr_reader :query_config

    # @usage
    # query = CebuPacFares::Query.new(from_date: Date.new(2019, 1, 1), to_date: Date.new(2019, 1, 30), from_destination: 'MNL', to_destination: 'SIN')
    # query.print_flights
    #
    def initialize(options)
      @query_config = QueryConfig.new(
        from_date: options[:from_date],
        to_date: options[:to_date],
        from_destination: options[:from_destination],
        to_destination: options[:to_destination]
      )
    end

    def print_flights
      from_date = query_config.from_date
      to_date = query_config.to_date

      (from_date..to_date).each do |date|
        flights = cached_date_flights_map[date.to_s]
        printf("#{date}:\n")

        flights.each do |flight|
          printf(
            "%-7s %-15s %-10s %-5s %s\n",
            flight.flight_number,
            "#{flight.departure_time} - #{flight.arrival_time}",
            "#{flight.from_airport} - #{flight.to_airport}",
            flight.duration,
            flight.price
          )
        end
        printf("\n")
      end

      printf("==== DONE ===")
    end

    def cached_date_flights_map
      @cached_date_flights_map ||= date_flights_map
    end

    def date_flights_map
      fetcher.fetch
    end

    private

    def fetcher
      @fetcher ||= Fetcher.new(query_config)
    end
  end
end

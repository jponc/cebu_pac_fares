module CebuPacFares
  class QueryConfig
    attr_reader :from_date,
                :to_date,
                :from_destination,
                :to_destination

    # @param [Hash] options
    # @option options [Date] :from_date
    # @option options [Date] :to_date
    # @option options [String] :from_destination
    # @option options [String] :to_destination
    #
    def initialize(options)
      @from_date = options[:from_date]
      @to_date = options[:to_date]
      @from_destination = options[:from_destination]
      @to_destination = options[:to_destination]
    end
  end
end

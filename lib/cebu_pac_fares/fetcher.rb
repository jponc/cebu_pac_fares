# TODO:
# Still need to implement sleep and retry functionality so it doesn't hit the captcha security issue
#

require 'typhoeus'
require 'open-uri'
require 'nokogiri'

module CebuPacFares
  class Fetcher
    attr_reader :query_config

    IS_ASYNC = true

    def initialize(query_config)
      @query_config = query_config
    end

    def fetch
      if IS_ASYNC
        send_requests_asynchronously
      else
        send_requests_synchronously
      end
    end

    private

    def send_requests_asynchronously
      map = {}
      hydra = Typhoeus::Hydra.new

      from_date = query_config.from_date
      to_date = query_config.to_date

      (from_date..to_date).each do |date|
        url = build_url(date)

        request = Typhoeus::Request.new(url)
        request.on_complete do |response|
          map[date.to_s] = extract_flights(response.body)
        end

        hydra.queue(request)
      end

      hydra.run

      map
    end

    def send_requests_synchronously
      map = {}

      from_date = query_config.from_date
      to_date = query_config.to_date

      (from_date..to_date).each do |date|
        url = build_url(date)
        response_body = open(url).read
        map[date.to_s] = extract_flights(response_body)
      end
      map
    end

    def build_url(date)
      from_destination = query_config.from_destination
      to_destination = query_config.to_destination
      "https://beta.cebupacificair.com/Flight/Select?o1=#{from_destination}&d1=#{to_destination}&o2=&d2=&dd1=#{date}&ADT=1&CHD=0&INF=0&inl=0&pos=cebu.ph&culture=&p="
    end

    def extract_flights(response_body)
      web_rows = extract_web_rows(response_body)
      web_rows.map do |web_row|
        convert_web_row_to_flight(web_row)
      end.compact
    end

    def extract_web_rows(response_body)
      doc = Nokogiri::HTML(response_body)
      doc.search('.faretable-row')
    end

    def convert_web_row_to_flight(web_row)
      return unless is_direct_flight?(web_row)

      Flight.new(
        flight_number: clean_content(web_row.xpath('th')[0].content)[0],
        departure_time: clean_content(web_row.xpath('td')[0].content)[0],
        arrival_time: clean_content(web_row.xpath('td')[0].content)[1],
        from_airport: clean_content(web_row.xpath('td')[2].content)[0],
        to_airport: clean_content(web_row.xpath('td')[2].content)[1],
        duration: clean_content(web_row.xpath('td')[3].content)[0],
        price: clean_content(web_row.xpath('td')[4].content)[0]
      )
    end

    def is_direct_flight?(web_row)
      web_row.xpath('th/div').count == 1
    end

    def clean_content(content)
      lines = content.split("\r\n")
      lines.map { |l| l.strip }.select { |l| !l.empty? }
    end
  end
end

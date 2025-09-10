require "json"
require "date"
require "debug"

module Level5
  class Car
    attr_reader :id, :price_per_day, :price_per_km

    def initialize(attrs)
      @id            = attrs["id"]
      @price_per_day = attrs["price_per_day"]
      @price_per_km  = attrs["price_per_km"]
    end
  end

  class Rental
    attr_reader :id, :options
    ACTORS = %w[driver owner insurance assistance drivy].freeze

    COMMISSION_RATE    = 30
    INSURANCE_RATE     = 50
    ASSISTANCE_FEE_DAY = 100

    OPTIONS = {
      "gps"                  => { price_per_day: 500,  beneficiary: :owner },
      "baby_seat"            => { price_per_day: 200,  beneficiary: :owner },
      "additional_insurance" => { price_per_day: 1000, beneficiary: :drivy }
    }.freeze

    def initialize(attrs, car, options)
      @id         = attrs["id"]
      @car        = car
      @start_date = Date.parse(attrs["start_date"])
      @end_date   = Date.parse(attrs["end_date"])
      @distance   = attrs["distance"]
      @options    = options

      validate!
    end

    def compute_options_price_for?(beneficiary)
      @options.sum do |opt|
        rental_option = OPTIONS[opt]
        next 0 unless rental_option
        rental_option[:beneficiary] == beneficiary ? rental_option[:price_per_day] * duration_in_days : 0
      end
    end

    def actors_payment
      base = base_price
      commission     = (base * COMMISSION_RATE) / 100
      insurance_fee  = (commission * INSURANCE_RATE) / 100
      assistance_fee = duration_in_days * ASSISTANCE_FEE_DAY
      drivy_fee      = commission - insurance_fee - assistance_fee
      owner_base     = base - commission

      options_credited_to_owner = compute_options_price_for?(:owner)
      options_credited_to_drivy = compute_options_price_for?(:drivy)

      [
        { who: "driver",    type: "debit",  amount: base + options_credited_to_owner + options_credited_to_drivy },
        { who: "owner",     type: "credit", amount: owner_base + options_credited_to_owner },
        { who: "insurance", type: "credit", amount: insurance_fee },
        { who: "assistance",type: "credit", amount: assistance_fee },
        { who: "drivy",     type: "credit", amount: drivy_fee + options_credited_to_drivy }
      ]
    end

    private

    def duration_in_days
      (@end_date - @start_date).to_i + 1
    end

    def base_price
      duration_price = discounted_days_price(duration_in_days, @car.price_per_day)
      distance_price = @distance * @car.price_per_km
      duration_price + distance_price
    end

    def discounted_days_price(days, price_per_day)
      total = 0
      1.upto(days) do |day|
        daily =
          if day == 1
            price_per_day
          elsif day <= 4
            (price_per_day * 90) / 100
          elsif day <= 10
            (price_per_day * 70) / 100
          else
            (price_per_day * 50) / 100
          end
        total += daily
      end
      total
    end

    def validate!
      raise ArgumentError, "end_date must be >= start_date" if @end_date < @start_date
      raise ArgumentError, "distance must be >= 0" if @distance < 0
      @options.each do |opt|
        raise ArgumentError, "Unknown option: #{opt}" unless OPTIONS.key?(opt)
      end
    end
  end

  input_path  = File.join(__dir__, "data", "input.json")
  output_path = File.join(__dir__, "data", "output.json")

  data = JSON.parse(File.read(input_path))
  cars = data["cars"].map { Car.new(_1) }
  cars_by_id = cars.to_h { |c| [c.id, c] }

  options = (data["options"] || [])

  rentals = data["rentals"].map do |rental|
    rental_options = options.select { |option| option["rental_id"] == rental["id"] }.map { |attrs| attrs["type"] }
    Rental.new(rental, cars_by_id.fetch(rental["car_id"]), rental_options)
  end

  puts "#{cars.size} cars found, #{rentals.size} rentals found"


  output = {
    rentals: rentals.map do |rental|
      { id: rental.id, options: rental.options, actions: rental.actors_payment }
    end
  }

  File.write(output_path, JSON.pretty_generate(output))
  puts "Wrote #{output_path}"
end

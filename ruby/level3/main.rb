require "json"
require "date"

module Level3
  class Car
    attr_reader :id, :price_per_day, :price_per_km

    def initialize(attrs)
      @id            = attrs["id"]
      @price_per_day = attrs["price_per_day"]
      @price_per_km  = attrs["price_per_km"]
    end
  end

  class Rental
    attr_reader :id, :car

    COMMISSION_RATE    = 30
    INSURANCE_RATE     = 50
    ASSISTANCE_FEE_DAY = 100

    def initialize(attrs, car)
      @id         = attrs["id"]
      @car        = car
      @start_date = Date.parse(attrs["start_date"])
      @end_date   = Date.parse(attrs["end_date"])
      @distance   = attrs["distance"]

      validate!
    end

    def total_price
      duration_price = discounted_days_price(duration_in_days, car.price_per_day)
      distance_price = @distance * car.price_per_km
      duration_price + distance_price
    end

    def commission
      commission     = (total_price * COMMISSION_RATE) / 100
      insurance_fee  = (commission * INSURANCE_RATE) / 100
      assistance_fee = duration_in_days * ASSISTANCE_FEE_DAY
      drivy_fee = commission - insurance_fee - assistance_fee

      {
        insurance_fee: insurance_fee.to_i,
        assistance_fee: assistance_fee,
        drivy_fee: drivy_fee.to_i
      }
    end

    private

    def validate!
      raise ArgumentError, "end_date must be >= start_date" if @end_date < @start_date
      raise ArgumentError, "distance must be >= 0" if @distance < 0
    end

    def duration_in_days
      (@end_date - @start_date).to_i + 1
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
  end

  input_path  = File.join(__dir__, "data", "input.json")
  output_path = File.join(__dir__, "data", "output.json")

  data = JSON.parse(File.read(input_path))
  cars = data["cars"].map { Car.new(_1) }
  cars_by_id = cars.to_h { |c| [c.id, c] }

  rentals = data["rentals"].map do |rental_attrs|
    Rental.new(rental_attrs, cars_by_id.fetch(rental_attrs["car_id"]))
  end

  puts "#{cars.size} cars found, #{rentals.size} rentals found"

  output = {
    rentals: rentals.map do |rental|
      { id: rental.id, price: rental.total_price, commission: rental.commission }
    end
  }

  File.write(output_path, JSON.pretty_generate(output))
  puts "Wrote #{output_path}"
end

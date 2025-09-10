require "json"
require "date"

module Level1
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

    def initialize(attrs, car)
      @id         = attrs["id"]
      @car        = car
      @start_date = Date.parse(attrs["start_date"])
      @end_date   = Date.parse(attrs["end_date"])
      @distance   = attrs["distance"]

      validate!
    end

    def total_price
      duration_price = duration_in_days * car.price_per_day
      distance_price = @distance * car.price_per_km
      duration_price + distance_price
    end

    private

    def validate!
      raise ArgumentError, "end_date must be >= start_date" if @end_date < @start_date
      raise ArgumentError, "distance must be >= 0" if @distance < 0
    end

    def duration_in_days
      (@end_date - @start_date).to_i + 1
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
      { id: rental.id, price: rental.total_price }
    end
  }

  File.write(output_path, JSON.pretty_generate(output))
  puts "Wrote #{output_path}"
end

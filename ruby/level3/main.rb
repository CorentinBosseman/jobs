require "json"
require "date"

class Car
  attr_reader :id, :price_per_day, :price_per_km

  def initialize(attrs)
    @id            = attrs["id"]
    @price_per_day = attrs["price_per_day"]
    @price_per_km  = attrs["price_per_km"]
  end
end

class Rental
  attr_reader :id, :car_id, :start_date, :end_date, :distance

  def initialize(attrs)
    @id         = attrs["id"]
    @car_id     = attrs["car_id"]
    @start_date = Date.parse(attrs["start_date"])
    @end_date   = Date.parse(attrs["end_date"])
    @distance   = attrs["distance"]
  end

  def total_price(car)
    duration_price = discounted_days_price(duration_in_days, car.price_per_day)
    distance_price = @distance * car.price_per_km
    duration_price + distance_price
  end

  def commission(car)
    total_price = total_price(car)
    commission = total_price * 0.3
    insurance_fee = commission * 0.5
    assistance_fee = duration_in_days * 100
    drivy_fee = commission - insurance_fee - assistance_fee

    {
      insurance_fee: insurance_fee.to_i,
      assistance_fee: assistance_fee,
      drivy_fee: drivy_fee.to_i
    }
  end

  private

  def duration_in_days
    (@end_date - @start_date).to_i + 1
  end

  def discounted_days_price(duration_in_days, price_per_day)
    total = 0
    1.upto(duration_in_days) do |day|
      case day
      when 1
        total += price_per_day
      when 2..4
        total += price_per_day * 0.9
      when 5..10
        total += price_per_day * 0.7
      else
        total += price_per_day * 0.5
      end
    end
    total.to_i
  end
end

input_path  = File.join(__dir__, "data", "input.json")
output_path = File.join(__dir__, "data", "output.json")

data = JSON.parse(File.read(input_path))
cars = data["cars"].map { Car.new(_1) }
rentals = data["rentals"].map { Rental.new(_1) }

puts "#{cars.size} cars found, #{rentals.size} rentals found"

cars_by_id = cars.to_h { |c| [c.id, c] }

output = {
  rentals: rentals.map do |rental|
    car = cars_by_id.fetch(rental.car_id)
    { id: rental.id, price: rental.total_price(car), commission: rental.commission(car) }
  end
}

File.write(output_path, JSON.pretty_generate(output))
puts "Wrote #{output_path}"

require "minitest/autorun"
require "json"
require_relative "../level1/main"

class Level1UnitTest < Minitest::Test
  Car    = Level1::Car
  Rental = Level1::Rental

  def car
    Car.new({ "id"=>1, "price_per_day"=>2000, "price_per_km"=>10 })
  end

  def rental_three_days
    attrs = {
      "id"         => 1,
      "car_id"     => 1,
      "start_date" => "2015-12-8",
      "end_date"   => "2015-12-10",
      "distance"   => 100
    }
    Rental.new(attrs, car)
  end

  def test_total_price_three_days
    # 3 days * 2000 + 100 km * 10 = 6000 + 1000 = 7000
    assert_equal 7000, rental_three_days.total_price
  end

  def test_output
    output_path   = File.join(__dir__, "data", "output.json")
    expected_path = File.join(__dir__, "data", "expected_output.json")

    output   = JSON.parse(File.read(output_path))
    expected = JSON.parse(File.read(expected_path))

    assert_equal expected, output
  end
end
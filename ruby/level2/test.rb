require "minitest/autorun"
require "json"
require_relative "../level2/main"

class Level2UnitTest < Minitest::Test
  Car    = Level2::Car
  Rental = Level2::Rental

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
    assert_equal 6600, rental_three_days.total_price
  end

  def test_output
    output_path   = File.join(__dir__, "data", "output.json")
    expected_path = File.join(__dir__, "data", "expected_output.json")

    output   = JSON.parse(File.read(output_path))
    expected = JSON.parse(File.read(expected_path))

    assert_equal expected, output
  end
end

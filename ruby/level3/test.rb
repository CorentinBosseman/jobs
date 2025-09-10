require "minitest/autorun"
require "json"
require_relative "../level3/main"

class Level3UnitTest < Minitest::Test
  Car    = Level3::Car
  Rental = Level3::Rental

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

  def test_commission_breakdown_three_days
    expected = { insurance_fee: 990, assistance_fee: 300, drivy_fee: 690 }
    assert_equal expected, rental_three_days.commission
  end

  def test_output
    output_path   = File.join(__dir__, "data", "output.json")
    expected_path = File.join(__dir__, "data", "expected_output.json")

    output   = JSON.parse(File.read(output_path))
    expected = JSON.parse(File.read(expected_path))

    assert_equal expected, output
  end
end

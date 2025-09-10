require "minitest/autorun"
require "json"
require_relative "../level4/main"

class Level4UnitTest < Minitest::Test
  Car    = Level4::Car
  Rental = Level4::Rental

  def car
    Car.new({ "id"=>1, "price_per_day"=>2000, "price_per_km"=>10 })
  end

  def rental
    attrs = {
      "id"         => 1,
      "car_id"     => 1,
      "start_date" => "2015-12-8",
      "end_date"   => "2015-12-10",
      "distance"   => 100
    }
    Rental.new(attrs, car)
  end

  def test_actors_payment_three_days
    expected = [
      { who: "driver",     type: "debit",  amount: 6600 },
      { who: "owner",      type: "credit", amount: 4620 },
      { who: "insurance",  type: "credit", amount: 990  },
      { who: "assistance", type: "credit", amount: 300  },
      { who: "drivy",      type: "credit", amount: 690  }
    ]
    assert_equal expected, rental.actors_payment
  end

  def test_output
    output_path   = File.join(__dir__, "data", "output.json")
    expected_path = File.join(__dir__, "data", "expected_output.json")

    output   = JSON.parse(File.read(output_path))
    expected = JSON.parse(File.read(expected_path))

    assert_equal expected, output
  end
end
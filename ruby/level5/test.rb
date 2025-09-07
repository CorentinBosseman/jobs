require "minitest/autorun"
require "json"
require_relative "../level5/main"

class Level5UnitTest < Minitest::Test
  Car    = Level5::Car
  Rental = Level5::Rental

  def car
    Car.new({ "id"=>1, "price_per_day"=>2000, "price_per_km"=>10 })
  end

  def rental
    attrs = {
      "id"         => 1,
      "car_id"     => 1,
      "start_date" => "2015-12-8",
      "end_date"   => "2015-12-8",
      "distance"   => 100
    }
    Rental.new(attrs, car, %w[gps baby_seat])
  end

  def test_expected_actors_payment
    actors = rental.actors_payment
    amounts = actors.to_h { |a| [a[:who], a[:amount]] }
    assert_equal 3700, amounts["driver"]
    assert_equal 2800, amounts["owner"]
    assert_equal  450, amounts["insurance"]
    assert_equal  100, amounts["assistance"]
    assert_equal  350, amounts["drivy"]
    assert_equal amounts["driver"], amounts["owner"] + amounts["insurance"] + amounts["assistance"] + amounts["drivy"]
  end

  def test_output
    output_path   = File.join(__dir__, "data", "output.json")
    expected_path = File.join(__dir__, "data", "expected_output.json")

    output   = JSON.parse(File.read(output_path))
    expected = JSON.parse(File.read(expected_path))

    assert_equal expected, output
  end
end
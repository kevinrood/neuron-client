module Neuron
  module Client
    module Model
      module Common
        class FakeZone
          include ZoneCalculations
          def initialize(ads, ad_links)
            @ads = ads
            @ad_links = ad_links
          end
          attr_reader :ad_links
          def find_ad(ad_id)
            @ads[ad_id]
          end
        end

        class ZoneCalculationSpecAd
          def initialize(active, pressure)
            @active = active
            @pressure = pressure
          end
          attr_reader :pressure, :active
          alias_method :active?, :active
        end

        describe ZoneCalculations do
          describe ".calculate_ads_by_priority" do
            it "should generate the expected result" do
              ads = {
                "0" => ZoneCalculationSpecAd.new(false, 42.0),
                "1" => ZoneCalculationSpecAd.new(true, 11.1),
                "2" => ZoneCalculationSpecAd.new(true, 11.1),
                "3" => ZoneCalculationSpecAd.new(true, 22.2),
                "4" => ZoneCalculationSpecAd.new(true, 1000),
                "5" => ZoneCalculationSpecAd.new(true, 828282)
              }
              ad_links = {
                "0" => {"priority" => 1, "weight" => 50},
                "1" => {"priority" => 1, "weight" => 4},
                "2" => {"priority" => 1, "weight" => 2},
                "3" => {"priority" => 1, "weight" => 2},
                "4" => {"priority" => 2, "weight" => 99.9}
              }
              zone = FakeZone.new(ads, ad_links)

              zone.calculate_ads_by_priority.should == [[["1", 44.4], ["2", 22.2], ["3", 44.4]], [["4", 99900.0]]]
            end
          end
        end

      end
    end
  end
end

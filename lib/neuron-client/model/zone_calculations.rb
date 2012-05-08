module Neuron
  module Client
    module ZoneCalculations
      # This module expects the following methods to be defined:
      #
      # ad_links (Hash, keys are ad IDs, values are a sub-hash: {'priority' => p, 'weight' => w})
      # find_ad(ad_id) (nil, or an object that responds to :active? and :pressure)

      def ads_by_priority
        calculate_ads_by_priority
      end

      def calculate_ads_by_priority
        entries = {}
        ad_links.each do |ad_id, link|
          next unless ad = find_ad(ad_id)
          pressure = ad.active? ? ad.pressure : nil
          next if pressure.nil?
          weight   = link['weight'].to_f
          priority = link['priority'].to_f
          entries[priority] ||= []
          entries[priority] << [ad_id, weighted_pressure(weight, pressure)]
        end
        entries.sort_by do |priority, entry|
          priority
        end.map do |priority, entry|
          entry.sort_by(&:first)
        end
      end

      private

      def weighted_pressure(weight, pressure)
        [( [weight, 0.0].max * [pressure, 1.0].max ), 1.0].max.to_f
      end
    end
  end
end

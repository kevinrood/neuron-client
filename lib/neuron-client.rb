require "active_support/core_ext"
require "neuron-client/version"
require "neuron-client/api"
require "neuron-client/connection"
require "neuron-client/connected"
require "neuron-client/ad_calculations"
require "neuron-client/zone_calculations"
require "neuron-client/ad"
require "neuron-client/ad_zone"
require "neuron-client/blocked_referer"
require "neuron-client/blocked_user_agent"
require "neuron-client/geo_target"
require "neuron-client/real_time_stats"
require "neuron-client/report"
require "neuron-client/s3_file"
require "neuron-client/zone"

class Object
  def blank?
    return true if self.nil?
    return true if self.respond_to?(:empty) && self.empty?
    false
  end

  def present?
    !self.blank?
  end
end
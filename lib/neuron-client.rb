require "rubygems"
require "tzinfo"
require "active_support" #TODO: when we upgrade to 3.x, this can be "active_support/core_ext"
require "active_support/core_ext"
require "json-schema"
require "neuron-client/version"
require "neuron-client/admin_connection"
require "neuron-client/membase_connection"
require "neuron-client/api"

require "neuron-client/model/base"
require "neuron-client/model/ad_calculations"
require "neuron-client/model/ad"
require "neuron-client/model/ad_zone"
require "neuron-client/model/blocked_referer"
require "neuron-client/model/blocked_user_agent"
require "neuron-client/model/geo_target"
require "neuron-client/model/pixel"
require "neuron-client/model/report"
require "neuron-client/model/s3_file"
require "neuron-client/model/zone_calculations"
require "neuron-client/model/zone"

require "neuron-client/schema/common.rb"
require "neuron-client/schema/ad.rb"
require "neuron-client/schema/ad_zone.rb"
require "neuron-client/schema/blocked_referer.rb"
require "neuron-client/schema/blocked_user_agent.rb"
require "neuron-client/schema/geo_target.rb"
require "neuron-client/schema/pixel.rb"
require "neuron-client/schema/report.rb"
require "neuron-client/schema/s3_file.rb"
require "neuron-client/schema/zone.rb"

class Object
  def blank?
    return true if self.nil?
    return true if self.respond_to?(:empty?) && self.empty?
    false
  end

  def present?
    !self.blank?
  end
end

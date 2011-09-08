require "rubygems"
require "tzinfo"
require "active_support" #TODO: when we upgrade to 3.x, this can be "active_support/core_ext"
require "active_support/core_ext"
require "neuron-client/version"
require "neuron-client/admin_connection"
require "neuron-client/membase_connection"
require "neuron-client/api"

require "neuron-client/model/common/base"
require "neuron-client/model/common/ad_calculations"
require "neuron-client/model/common/ad"
require "neuron-client/model/common/ad_zone"
require "neuron-client/model/common/blocked_referer"
require "neuron-client/model/common/blocked_user_agent"
require "neuron-client/model/common/geo_target"
require "neuron-client/model/common/report"
require "neuron-client/model/common/s3_file"
require "neuron-client/model/common/zone_calculations"
require "neuron-client/model/common/zone"

require "neuron-client/model/admin/base"
require "neuron-client/model/admin/ad"
require "neuron-client/model/admin/ad_zone"
require "neuron-client/model/admin/blocked_referer"
require "neuron-client/model/admin/blocked_user_agent"
require "neuron-client/model/admin/geo_target"
require "neuron-client/model/admin/report"
require "neuron-client/model/admin/s3_file"
require "neuron-client/model/admin/zone"

require "neuron-client/model/membase/ad"
require "neuron-client/model/membase/ad_zone"
require "neuron-client/model/membase/blocked_referer"
require "neuron-client/model/membase/blocked_user_agent"
require "neuron-client/model/membase/geo_target"
require "neuron-client/model/membase/report"
require "neuron-client/model/membase/s3_file"
require "neuron-client/model/membase/zone"

require "neuron-client/model/base"
require "neuron-client/model/models"

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

# lifted completely from the ruby facets gem source:
# /lib/core-uncommon/facets/module/cattr.rb
def Module
  def cattr_writer(*syms)
    syms.flatten.each do |sym|
      module_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end

        def #{sym}=(obj)
          @@#{sym}=(obj)
        end
      EOS
    end
    return syms
  end
end

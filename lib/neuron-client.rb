require "active_support/core_ext"
require "neuron-client/version"
require "neuron-client/base"

require "neuron-client/membase/connection"
require "neuron-client/membase/base"
require "neuron-client/membase/ad"
require "neuron-client/membase/ad_zone"
require "neuron-client/membase/blocked_user_agent"
require "neuron-client/membase/blocked_referer"
require "neuron-client/membase/geo_target"
require "neuron-client/membase/report"
require "neuron-client/membase/s3_file"
require "neuron-client/membase/zone"

require "neuron-client/admin/connection"
require "neuron-client/admin/base"
require "neuron-client/admin/ad"
require "neuron-client/admin/ad_zone"
require "neuron-client/admin/blocked_user_agent"
require "neuron-client/admin/blocked_referer"
require "neuron-client/admin/geo_target"
require "neuron-client/admin/report"
require "neuron-client/admin/s3_file"
require "neuron-client/admin/zone"

require "neuron-client/api"
require "neuron-client/ad_calculations"
require "neuron-client/zone_calculations"
require "neuron-client/ad"
require "neuron-client/ad_zone"
require "neuron-client/blocked_user_agent"
require "neuron-client/blocked_referer"
require "neuron-client/geo_target"
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

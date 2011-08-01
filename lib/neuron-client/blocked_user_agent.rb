module Neuron
  module Client
    class BlockedUserAgent
      include Connected
      resource_name("blocked_user_agent")
      resources_name("blocked_user_agents")

      attr_accessor :user_agent, :description, :created_at, :updated_at

    end
  end
end
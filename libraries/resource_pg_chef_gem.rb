require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class PgChefGem < Chef::Resource::LWRPBase
      self.resource_name = :pg_chef_gem
      actions :install, :remove
      default_action :install

      attribute :pg_chef_gem_name, kind_of: String, name_attribute: true, required: true
      attribute :gem_version, kind_of: String, default: '0.18.2'
    end
  end
end

if defined?(ChefSpec)
  def install_mysql2_chef_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:pg_chef_gem, :install, resource_name)
  end
end

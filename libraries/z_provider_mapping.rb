#########
# pg_chef_gem
#########
Chef::Platform.set platform: :centos, resource: :pg_chef_gem, provider: Chef::Provider::PgChefGem
Chef::Platform.set platform: :debian, resource: :pg_chef_gem, provider: Chef::Provider::PgChefGem
Chef::Platform.set platform: :ubuntu, resource: :pg_chef_gem, provider: Chef::Provider::PgChefGem

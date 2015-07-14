source 'https://supermarket.chef.io'

cookbook 'postgresql',
  github: 'patcon/postgresql',
  branch: 'feature/pg_chef_gem'

metadata

group :integration do
  cookbook 'apt'
  cookbook 'test-helper',
    # Pending release: Add ohai attribute support (automatic attrs)
    # Ref: https://github.com/lipro-cookbooks/test-helper/pull/2
    github: 'lipro-cookbooks/test-helper'
  cookbook 'yum'
end

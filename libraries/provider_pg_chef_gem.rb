class Chef
  class Provider
    class PgChefGem < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :install do
        include_recipe 'build-essential::default'

        include_recipe 'postgresql::client'

        begin
          gem_package 'pg' do
            gem_binary RbConfig::CONFIG['bindir'] + '/gem'
            version new_resource.gem_version
            action :install
          end
        rescue Gem::Installer::ExtensionBuildError, Mixlib::ShellOut::ShellCommandFailed => e
          # Are we an omnibus install?
          raise if RbConfig.ruby.scan(%r{(chef|opscode)}).empty?
          # Still here, must be omnibus. Lets make this thing install!
          Chef::Log.warn 'Failed to properly build pg gem. Forcing properly linking and retrying (omnibus fix)'
          gem_dir = e.message.scan(%r{will remain installed in ([^ ]+)}).flatten.first
          raise unless gem_dir
          gem_name = File.basename(gem_dir)
          ext_dir = File.join(gem_dir, 'ext')
          gem_exec = File.join(File.dirname(RbConfig.ruby), 'gem')
          new_content = <<-EOS
      require 'rbconfig'
      %w(
      configure_args
      LIBRUBYARG_SHARED
      LIBRUBYARG_STATIC
      LIBRUBYARG
      LDFLAGS
      ).each do |key|
        RbConfig::CONFIG[key].gsub!(/-Wl[^ ]+( ?\\/[^ ]+)?/, '')
        RbConfig::MAKEFILE_CONFIG[key].gsub!(/-Wl[^ ]+( ?\\/[^ ]+)?/, '')
      end
      RbConfig::CONFIG['RPATHFLAG'] = ''
      RbConfig::MAKEFILE_CONFIG['RPATHFLAG'] = ''
      EOS
          new_content << File.read(extconf_path = File.join(ext_dir, 'extconf.rb'))
          File.open(extconf_path, 'w') do |file|
            file.write(new_content)
          end

          execute 'generate pg gem Makefile' do
            # [COOK-3490] pg gem install requires full path on RHEL
            command "PATH=$PATH:/usr/pgsql-#{node['postgresql']['version']}/bin #{RbConfig.ruby} extconf.rb"
            cwd ext_dir
          end

          execute 'make pg gem lib' do
            command 'make'
            cwd ext_dir
          end

          execute 'install pg gem lib' do
            command 'make install'
            cwd ext_dir
          end

          execute 'install pg spec' do
            command "#{gem_exec} spec ./cache/#{gem_name}.gem --ruby > ./specifications/#{gem_name}.gemspec"
            cwd File.join(gem_dir, '..', '..')
          end

          Chef::Log.warn 'Installation of pg gem successful!'
        end

      end

      action :remove do
        gem_package 'pg' do
          gem_binary RbConfig::CONFIG['bindir'] + '/gem'
          action :remove
        end
      end
    end
  end
end

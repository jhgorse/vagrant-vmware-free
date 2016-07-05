module VagrantPlugins
  module ProviderVMwareFree
    module Action
      class Import
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger::new('vagrant::provider::vmware-free::action::import')
        end

        def call(env)
          env[:ui].info I18n.t("vagrant.actions.vm.import.importing",
                               :name => env[:machine].box.name)

          # Import the virtual machine
          vmx_file = Dir.glob(env[:machine].box.directory.join('*.vmx'))[0]
          dest_file = env[:machine].data_dir.join(File.basename(vmx_file))

          @logger.debug("vmx_file: #{vmx_file}  dest_file: #{dest_file.to_s}")

          env[:machine].id = env[:machine].provider.driver.import(vmx_file, dest_file.to_s) do |progress|
            env[:ui].clear_line
            env[:ui].report_progress(progress, 100, false)
          end

          # Clear the line one last time since the progress meter doesn't disappear
          # immediately.
          env[:ui].clear_line

          # If we got interrupted, then the import could have been
          # interrupted and its not a big deal. Just return out.
          return if env[:interrupted]

          # Flag as erroneous and return if import failed
          raise Vagrant::Errors::VMImportFailure if !env[:machine].id

          # Import completed successfully. Continue the chain
          @app.call(env)
        end

        def recover(env)
          if env[:machine].provider.state.id != :not_created
            return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

            # If we're not supposed to destroy on error then just return
            return if !env[:destroy_on_error]

            # Interrupted, destroy the VM. We note that we don't want to
            # validate the configuration here, and we don't want to confirm
            # we want to destroy.
            destroy_env = env.clone
            destroy_env[:config_validate] = false
            destroy_env[:force_confirm_destroy] = true
            env[:action_runner].run(Action.action_destroy, destroy_env)
          end
        end
      end
    end
  end
end

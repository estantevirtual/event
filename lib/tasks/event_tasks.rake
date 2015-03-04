require 'fileutils'
namespace :event do
  desc "Installs required stuff to event"
  task :install do
    Rails.logger = Logger.new(STDOUT)
    source = File.join(Gem.loaded_specs["event"].full_gem_path, "lib/config", "event.yml")
    target = File.join("config", "event.yml")
    Rails.logger.info "Creating file #{target}"
    FileUtils.cp_r(source, target)

    source = File.join(Gem.loaded_specs["event"].full_gem_path, "lib/config/initializers", "setup_event.rb")
    target = File.join("config/initializers", "setup_event.rb")
    Rails.logger.info "Creating file #{target}"
    FileUtils.cp_r(source, target)
  end
end
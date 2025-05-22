#!/usr/bin/env ruby

require 'thor'
require 'fileutils'

class ApplicationPrepare < Thor
  desc 'setup_action [OPTIONS]', 'Modifies bin/omakub-sub/install.sh as needed'

  def setup_action
    say "Add Optional Apps entry in the menu", :green
    insert_into_file "config/environment.rb", :after => "Dev Database      Install development database in Docker\n" do
      <<-EOF
  Optional Apps    Install optional apps in Docker
  EOF
    end
  end

  no_commands do
    def add_menu_entry
  end
end

#!/usr/bin/env ruby

require 'thor'
require 'fileutils'

class ApplicationPrepare < Thor
  desc 'setup_action [OPTIONS]', 'Modifies bin/omakub-sub/install.sh as needed'

  def setup_action
    say "Add Optional Apps entry in the menu", :green
    # Call the method to add the entry
  end

  no_commands do
    # Add helper methods here
  end
end

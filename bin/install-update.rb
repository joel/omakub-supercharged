#!/usr/bin/env ruby

require 'thor'
require 'fileutils'

class ApplicationPrepare < Thor
  desc 'setup_action [OPTIONS]', 'Updates $OMAKUB_PATH/bin/omakub-sub/install.sh to add Optional Apps entry as in install-to.sh template.'

  def setup_action
    omakub_path = ENV['OMAKUB_PATH'] || File.expand_path('~/.local/share/omakub-supercharged')
    target_file = File.join(omakub_path, 'bin/omakub-sub/install.sh')

    unless File.exist?(target_file)
      say "Target file not found: #{target_file}", :red
      exit 1
    end

    menu_entry = '  "Optional Apps     Install optional applications"\n'
    case_entry = '  "optional-apps") INSTALLER_FILE=\"$OMAKUB_PATH/bin/omakub-sub/install-optional-apps.sh\" ;;\n'

    file_content = File.read(target_file)
    already_has_menu = file_content.include?(menu_entry.strip)
    already_has_case = file_content.include?(case_entry.strip)

    # Insert menu entry after Dev Database
    dev_database_entry = /  "Dev Database      Install development database in Docker"\n/
    unless already_has_menu
      inject_into_file target_file, menu_entry, after: dev_database_entry
      say "Added menu entry to #{target_file} after Dev Database.", :green
    else
      say "Menu entry already present in #{target_file}.", :yellow
    end

    # Insert the case entry after the dev-editor case
    dev_editor_case = /"dev-editor"\).*\n/
    unless already_has_case
      inject_into_file target_file, case_entry, after: dev_editor_case
      say "Added case entry to #{target_file}.", :green
    else
      say "Case entry already present in #{target_file}.", :yellow
    end
  end

  no_commands do
    # Helper methods can be added here if needed
  end
end

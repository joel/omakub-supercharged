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

    menu_entry = "  \"Optional Apps     Install optional applications\"\n"
    case_entry = "  \"optional-apps\") INSTALLER_FILE=\\\"$OMAKUB_PATH/bin/omakub-sub/install-optional-apps.sh\\\" ;;\n"

    lines = File.readlines(target_file)
    already_has_menu = lines.any? { |l| l.strip == menu_entry.strip }
    already_has_case = lines.any? { |l| l.strip == case_entry.strip }

    # Insert menu entry after Dev Database
    unless already_has_menu
      dev_db_index = lines.find_index { |l| l =~ /  \"Dev Database      Install development database in Docker\"/ }
      if dev_db_index
        lines.insert(dev_db_index + 1, menu_entry)
        say "Added menu entry to #{target_file} after Dev Database.", :green
      else
        say "Dev Database entry not found. Menu entry not added.", :red
      end
    else
      say "Menu entry already present in #{target_file}.", :yellow
    end

    # Insert the case entry after the dev-editor case
    unless already_has_case
      dev_editor_index = lines.find_index { |l| l =~ /\"dev-editor\"\)/ }
      if dev_editor_index
        # Find the end of the dev-editor case (look for the next ';;' after dev-editor)
        case_end_index = lines[dev_editor_index..].find_index { |l| l.strip.end_with?(';;') }
        insert_at = dev_editor_index + (case_end_index ? case_end_index + 1 : 1)
        lines.insert(insert_at, case_entry)
        say "Added case entry to #{target_file}.", :green
      else
        say "dev-editor case entry not found. Case entry not added.", :red
      end
    else
      say "Case entry already present in #{target_file}.", :yellow
    end

    # Write back to file if any changes were made
    unless already_has_menu && already_has_case
      File.open(target_file, 'w') { |f| f.write(lines.join) }
    end
  end

  no_commands do
    # Helper methods can be added here if needed
  end
end

ApplicationPrepare.start(ARGV)
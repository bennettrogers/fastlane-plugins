module Fastlane
  module Helper
    class FetchItcVersionsHelper
      # Print a table
      def self.print_table(title, headings, data, style)
        return if data.count == 0

        if style == "pretty"

          require 'terminal-table'
          rows = []
          data.each do |type, versions|
            versions.each do |version|
              version_nr = version["version"]
              build_nr = version["build"]
              rows << [type, version_nr, build_nr]
            end
          end
          puts ""
          puts Terminal::Table.new(
            title: title,
            headings: headings,
            rows: rows
          )
          puts ""
        elsif style == "json"
          require 'json'
          puts "app_versions: #{data.to_json}"
        else
          UI.user_error!("You must provide a style for printing the output")
        end
      end
    end
  end
end

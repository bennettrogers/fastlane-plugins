module Fastlane
  module Actions
    class FetchItcVersionsAction < Action
      def self.run(params)
        require 'spaceship'

        UI.message("Login to iTunes Connect (#{params[:username]})")
        Spaceship::Tunes.login(params[:username])
        Spaceship::Tunes.select_team
        UI.message("Login successful")

        app = Spaceship::Tunes::Application.find(params[:app_identifier])

        data = {}

        train_versions = app.build_trains.keys

        edit_versions = []
        train_versions.each do |version|
          build_nr = app.build_trains[version].builds.map(&:build_version).map(&:to_i).sort.last
          entry = { version: version, build: build_nr }
          edit_versions.push(entry)
        end
        data["edit"] = edit_versions

        data["live"] = []
        if app.live_version
          data["live"] = [{ version: app.live_version.version, build: app.live_version.build_version }]
        end

        headings = ["Type", "Version", "Latest Build"]
        Helper::FetchItcVersionsHelper.print_table("App Versions", headings, data, params[:style])
      end

      def self.description
        "Returns a listing of all app versions and their latest builds from iTunes Connect."
      end

      def self.authors
        ["bennettrogers"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin returns version and latest build number data for each version of an app in iTunes Connect. The output can be formatted in a human-readable table, or as json for easier parsing."
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        [
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "FASTLANE_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "FETCH_ITC_VERSIONS_USER",
                                       description: "Your Apple ID Username",
                                       default_value: user),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "FETCH_ITC_VERSIONS_LIVE_TEAM_ID",
                                       description: "The ID of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :style,
                                       short_option: "-s",
                                       env_name: "FETCH_ITC_VERSIONS_STYLE",
                                       description: "How to print the version table - pretty or json",
                                       default_value: "pretty")
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
        true
      end
    end
  end
end

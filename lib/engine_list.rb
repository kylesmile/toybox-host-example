# frozen_string_literal: true

module Toybox
  ENGINES_DIRECTORY = File.expand_path("../engines", __dir__)

  # Central definition of the list of engines. Used for config throughout the host app.
  ENGINE_LIST = Dir.children(ENGINES_DIRECTORY)
    .keep_if { File.directory?(File.join(ENGINES_DIRECTORY, it)) }
    .each(&:freeze)
    .freeze

  module GuestApps
    def self.each_engine
      ENGINE_LIST.each do |engine_name|
        engine_module = engine_name.camelize.safe_constantize
        next if engine_module.nil?

        yield engine_module
      end
    end

    def self.each_public_engine
      each_engine do |engine_module|
        next unless engine_module::GUEST_INFO[:public]

        yield engine_module
      end
    end

    def self.engine_url(engine_module)
      root_host = Rails.application.config.root_host
      protocol = Rails.env.production? ? "https" : "http"

      "#{protocol}://#{engine_module::SUBDOMAIN}.#{root_host}"
    end
  end
end

# frozen_string_literal: true

module Toybox
  ENGINES_DIRECTORY = File.expand_path("../engines", __dir__)

  # Central definition of the list of engines. Used for config throughout the host app.
  ENGINE_LIST = Dir.children(ENGINES_DIRECTORY)
    .keep_if { File.directory?(File.join(ENGINES_DIRECTORY, it)) }
    .each(&:freeze)
    .freeze
end

# Template for creating new guest app engines
# See README.md for usage

# Add Slim to the gemspec
inject_into_file "#{name}.gemspec", after: /spec.add_dependency "rails", .*$/ do
  <<-RUBY

  spec.add_dependency "slim"

  # TEMP: Remove when there is a Rails release with Minitest 6 compatibility
  spec.add_development_dependency "minitest", "< 6"
  RUBY
end

# Create a basic layout with Optics CSS
create_file "app/views/layouts/#{name}/application.html.slim" do
  <<-SLIM
doctype html
html data-theme-mode="light"
  head
    title #{name.titleize}
    meta name="viewport" content="width=device-width,initial-scale=1"
    = csrf_meta_tags
    = csp_meta_tag
    = stylesheet_link_tag "https://cdn.jsdelivr.net/npm/@rolemodel/optics@2.2.0/dist/css/optics.min.css", "data-turbo-track": "reload"
    = stylesheet_link_tag "#{name}/application", "data-turbo-track": "reload"
    = javascript_importmap_tags
  body.app-body
    - flash.each do |kind, message|
      .alert.alert--flash class="alert--\#{kind}"
        .alert__message
          .alert__title = kind.titleize
          .alert__description = message
    .app__header
      .navbar
        = link_to "#{name.titleize}", root_path
        = yield :header
    .app__content
      = yield
    .app__footer
  SLIM
end

# Add subdomain constant
create_file "lib/#{name}/subdomain.rb" do
  <<-RUBY
# frozen_string_literal: true

module #{name.camelize}
  SUBDOMAIN = "#{name.dasherize}"
end
  RUBY
end

inject_into_file "lib/#{name}.rb", after: "require \"#{name}/version\"\n" do
  <<-RUBY
require "#{name}/subdomain"
  RUBY
end

inject_into_module "lib/#{name}.rb", name.camelize do
  <<-RUBY
  GUEST_INFO = {
    public: true,
    title: "#{name.humanize}",
    description: "Description for #{name.humanize}",
    source_url: "https://github.com"
  }
  RUBY
end

# Add asset precompilation configuration
inject_into_file "lib/#{name}/engine.rb", after: "isolate_namespace #{name.camelize}\n" do
  <<-RUBY
    # Make sure root host is defined for tests
    initializer "#{name}.root_host" do |app|
      next if app.config.respond_to?(:root_host)

      app.config.root_host = ""
    end

    initializer "#{name}.mount" do |app|
      app.routes.prepend do
        constraints subdomain: SUBDOMAIN do
          mount #{name.camelize}::Engine => "/"
        end
      end
    end

    initializer "#{name}.host" do |app|
      app.config.hosts << [SUBDOMAIN, app.config.root_host].compact_blank.join(".")
    end

    initializer "#{name}.assets.precompile" do |app|
      app.config.assets.precompile += %w[ #{name}/application.css ]
    end
  RUBY
end

# Remove table name prefix (this setup is intended to use multiple databases)
inject_into_file "lib/#{name}/engine.rb", before: "  class Engine < ::Rails::Engine" do
  <<-RUBY
  def self.table_name_prefix
    ""
  end

  RUBY
end

# Add DB connection setup
inject_into_file "app/models/#{name}/application_record.rb", after: "self.abstract_class = true\n" do
  <<-RUBY
    connects_to shards: {
      #{name}: { writing: :#{name}, reading: :#{name} }
    }
  RUBY
end

gsub_file "test/dummy/config/database.yml", "  <<: *default\n  database: storage/test.sqlite3" do
  <<-YAML
  primary:
    <<: *default
    database: storage/test.sqlite3
  #{name}:
    <<: *default
    database: storage/test.sqlite3
  YAML
end

gsub_file! "test/dummy/config/routes.rb", "  mount #{name.camelize}::Engine => \"/#{name}\"\n", ""

# Create home page so the engine works out of the box
create_file "app/views/#{name}/application/home.html.slim" do
  <<-SLIM
h1 Hello, #{name.humanize}!

p This is the template home page for your new guest app!
  SLIM
end

# Set up the root route
inject_into_file "config/routes.rb", after: "#{name.camelize}::Engine.routes.draw do\n" do
  <<-RUBY
  root to: "application#home"
  RUBY
end

inject_into_file "test/dummy/config/application.rb", "require \"slim\"\n", before: "Bundler.require"
inject_into_class "test/dummy/config/application.rb", "Application", "    config.root_host = \"example.com\"\n"

# Remove ERB layout
remove_file "app/views/layouts/#{name}/application.html.erb"

inject_into_file ".gitignore", after: "/test/dummy/tmp/" do
  <<-GITIGNORE


/node_modules
/.yarn/

/test/dummy/app/assets/builds/*
!/test/dummy/app/assets/builds/.keep
  GITIGNORE
end

create_file "app/javascript/#{name}/application.js"

append_to_file "test/test_helper.rb" do
  <<-RUBY
FileUtils.chdir File.expand_path("../", __dir__) do
  system("yarn build:test")
end
  RUBY
end

create_file "package.json" do
  <<-JSON
{
  "name": "#{name}",
  "type": "module",
  "packageManager": "yarn@4.12.0",
  "scripts": {
    "build:test": "esbuild app/javascript/#{name}/*.* --bundle --sourcemap --format=esm --outdir=test/dummy/app/assets/builds/#{name} --public-path=/assets"
  },
  "devDependencies": {
    "esbuild": "^0.27.2"
  }
}
  JSON
end

create_file "yarn.lock"
create_file "test/dummy/app/assets/builds/.keep"

run("yarn install")

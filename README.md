# README

This is an example of the setup used to host multiple apps within one host Rails app for toybox.kylecoding.com. It is not the actual configuration because that includes some private guest apps, but it is close and can be used as a starting point for anyone wanting a similar setup.

## The Toybox Concept

For a longer discussion of how this is put together, see my [blog post](https://kylecoding.com/sharing-my-toys). The short version is below.

I wanted to host multiple Rails apps while keeping costs low, so that I could deploy various "toy" projects (thus the "toybox" name). My solution is this repository: a single host Rails app, with guest apps as engines. This allows me to run multiple apps on a single server with significantly less resource usage than directly running multiple Rails apps.

## Setup

Clone the repository with submodules:
```shell
git clone --recurse-submodules https://github.com/kylesmile/toybox-host-example.git
```

Install the version of Ruby specified in the `.ruby-version` file, and the version of Node specified in the `.node-version` file.

Install dependencies
```shell
bundle install
corepack enable # Set up to use Yarn 4. Only needed for the initial setup.
yarn install
```

## Running the app

Start the app in development:

```shell
bin/dev
```

Then, visit http://toybox.kylecoding.localhost:3000 in a browser for the host app, or one of the subdomains for a guest app, such as http://books.toybox.kylecoding.localhost:3000.

## Creating new engines

Generate the engine from the template, replacing `<engine_name>` with the desired name of the engine:
```shell
rails plugin new engines/<engine_name> --mountable --full --template=./engines/template.rb --skip-gemfile-entry --skip-ci
bundle install
```

To track the engine in the main repository, either run the `rails plugin new` command with `--skip-git`, or run this:
```shell
rm -rf engines/<engine_name>.git
```

To track the engine in its own repository, replacing `<remote_url>` with the URL of the remote Git repository:
```shell
# Commit the files from generating the engine
cd engines/<engine_name>
git commit -am "Generate new engine"
git remote add origin <remote_url>
git push origin HEAD --set-upstream

# Set up the engine as a submodule
cd ../../
git submodule add <remote_url> engines/<engine_name>
git submodule absorbgitdirs engines/books
```

## License

[MIT](./LICENSE)

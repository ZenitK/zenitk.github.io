#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script currently supports Debian and Ubuntu systems with apt-get." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to install Ruby and build tools." >&2
  exit 1
fi

echo "Installing Ruby, Ruby development headers, and build tools..."
sudo apt-get update
sudo apt-get install -y ruby-full ruby-dev build-essential

export GEM_HOME="${GEM_HOME:-$PWD/.bundle/gems}"
export GEM_PATH="$GEM_HOME${GEM_PATH:+:$GEM_PATH}"
export PATH="$GEM_HOME/bin:$PATH"
mkdir -p "$GEM_HOME"

if ! command -v bundle >/dev/null 2>&1; then
  echo "Installing Bundler into $GEM_HOME..."
  gem install --no-document --user-install bundler
  export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
fi

echo "Installing project gems into $GEM_HOME..."
bundle config set --local path "$GEM_HOME"
bundle install

echo "Building the Jekyll site..."
bundle exec jekyll build

echo "Build complete. Generated site is in _site/."

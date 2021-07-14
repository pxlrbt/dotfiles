#!/bin/sh

echo "Setting up your Mac..."

xcode-select --install

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

export PATH="/opt/homebrew/bin:$PATH"

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew cleanup

brew service start asimov
brew service start nginx
brew service start mailhog
brew service start mariadb
brew service start php@7.4

export PATH="/opt/homebrew/bin:$PATH"

# Set fish as default shell
if ! cat /etc/shells | grep fish; then
  echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
  chsh -s /opt/homebrew/bin/fish
fi

# Set default MySQL root password and auth type
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
pecl install redis xdebug

# Install bass
git clone https://github.com/edc/bass.git /tmp/bass && cd /tmp/bass && make install

# Create a Sites directory
mkdir $HOME/Code

# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg
mackup restore

# Install global Composer packages
composer global install
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Install Laravel Valet
valet install

# Set macOS preferences - we will run this last because this will reload the shell
sh macos-settings.sh

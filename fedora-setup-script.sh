#!/bin/bash

# Laptop Setup Script

# Exit on error
set -e

# Detect OS
OS=$(cat /etc/os-release | grep "^ID=" | cut -d"=" -f2)

# Install prerequisites based on OS
echo "Detecting operating system..."
case "$OS" in
    fedora)
        echo "Installing packages for Fedora..."
        sudo dnf update --refresh -y
        sudo dnf install -y \
            fzf gvfs-smb gstreamer1-vaapi nodejs-npm liberation-fonts \
            libtool mousepad mediawriter btop tmux emacs eza gh hugo fd-find \
            ripgrep aspell pandoc cmake vlc anaconda powerline \
            powerline-fonts tmux-powerline flatpak mutt neofetch neovim offlineimap openssh-askpass \
            ansible podman podman-docker podman-compose v4l2loopback yt-dlp \
            zathura zathura-plugins-all zsh kitty golang rust mpv tldr
        ;;
    ubuntu|debian)
        echo "Installing packages for Ubuntu/Debian..."
        sudo apt update -y
        sudo apt install -y \
            fzf gvfs-smb gstreamer1.0-vaapi nodejs npm fonts-liberation \
            libtool mousepad mediawriter btop tmux emacs eza gh hugo fd-find \
            ripgrep aspell pandoc cmake vlc powerline fonts-powerline \
            flatpak mutt neofetch neovim offlineimap openssh-client \
            ansible podman podman-compose podman-docker \
            zathura zsh kitty golang rust mpv tldr
        ;;
    *)
        echo "Operating system not supported."
        exit 1
        ;;
esac

# Install Oh-My-ZSH if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh-My-Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh-My-Zsh already installed."
fi

# Install Oh-My-ZSH Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    echo "Installing zsh-autocomplete plugin..."
    git clone https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
fi
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    echo "Installing fast-syntax-highlighting plugin..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
fi

# Install Nerd Font Hack
FONT_DIR="$HOME/.local/share/fonts/Hack"
if [ ! -d "$FONT_DIR" ]; then
    echo "Installing Hack Nerd Font..."
    mkdir -p "$FONT_DIR"
    wget -O /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
    unzip /tmp/Hack.zip -d "$FONT_DIR"
    fc-cache -v
else
    echo "Hack Nerd Font already installed."
fi

# Install Flatpaks
echo "Setting up Flatpak and Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
FLATPAKS=(
    md.obsidian.Obsidian
    com.obsproject.Studio
    com.discordapp.Discord
    com.slack.Slack
    one.ablaze.floorp
    com.brave.Browser
    org.wezfurlong.wezterm
)

for app in "${FLATPAKS[@]}"; do
    echo "Installing $app..."
    flatpak install -y "$app"
done

# Clone and install auto-cpufreq
if [ ! -d "./auto-cpufreq" ]; then
    echo "Cloning and installing auto-cpufreq..."
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq && sudo ./auto-cpufreq-installer
    cd ..
else
    echo "auto-cpufreq already installed."
fi

# Create auto-cpufreq configuration file
sudo tee /etc/auto-cpufreq.conf << EOF
# settings for when connected to a power source
[charger]
governor = performance

[battery]
governor = powersave
EOF

# Available Aliases
echo "Setting up aliases..."
cat << 'EOF' >> ~/.zshrc

# My Aliases
alias l="eza -l -a --icons"
alias ls="eza --icons"
alias ll="eza -l -g --icons"
alias lla="eza -l -a -g --icons"
alias vim="nvim"
alias vi="nvim"
alias nf="neofetch"
alias kc="nvim ~/.config/hypr/UserConfigs/UserKeybinds.conf"
alias mon="nvim ~/.config/hypr/UserConfigs/Monitors.conf"
alias emc="emacsclient -c -a 'emacs'"
alias icat="kitten icat"
alias 000="chmod -R 000"
alias 644="chmod -R 644"
alias 666="chmod -R 666"
alias 755="chmod -R 755"
alias 777="chmod -R 777"
alias h="history | grep "
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias rb="source ~/.zshrc"
EOF

echo "Setup complete. Please reboot your system."

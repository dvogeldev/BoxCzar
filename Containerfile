FROM docker.io/library/archlinux:base-devel

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="btwiusemacs@fastmail.us>"

# COPY etc /etc

# Pacman Initialization
RUN sed -i 's/#Color/Color/g' /etc/pacman.conf && \
printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | tee -a /etc/pacman.conf && \
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf && \
pacman-key --init && \
pacman-key --populate archlinux && \
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com && \
pacman-key --lsign-key FBA220DFC880C036 && \
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm && \
printf "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | tee -a /etc/pacman.conf && \
pacman -Syu --noconfirm && \
pacman -S \
wget \
base-devel \
git \
--noconfirm

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
  echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Distrobox Integration
USER build
WORKDIR /home/build
RUN git clone https://github.com/KyleGospo/xdg-utils-distrobox-arch.git --single-branch && \
  cd xdg-utils-distrobox-arch/trunk && \
  makepkg -si --noconfirm && \
  cd ../.. && \
  rm -drf xdg-utils-distrobox-arch
USER root
WORKDIR /
RUN git clone https://github.com/89luca89/distrobox.git --single-branch && \
  cp distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec && \
  ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak && \
  ln -s /usr/bin/distrobox-host-exec /usr/bin/firefox && \
  ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
  ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
  wget https://github.com/1player/host-spawn/releases/download/$(cat distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O distrobox/host-spawn && \
  cp distrobox/host-spawn /usr/bin/host-spawn && \
  chmod +x /usr/bin/host-spawn && \
  rm -drf distrobox

# Install needed packages
RUN pacman -S \
  age \
  aria2 \
  atuin \
  bat \
  bottom \
  chezmoi \
  cosign \
  dbus \
  direnv \
  exa \
  fd \
  fish \
  ffmpeg \
  fzf \
  github-cli \
  just \
  lazygit \
  make \
  ncdu \
  ncurses \
  neofetch \
  neovim \
  npm \
  openssh \
  python3 \
  rbw \
  ripgrep \
  rustup \
  skim \
  speedtest-cli \
  starship \
  tealdeer \
  unzip \
  zellij \
  zoxide \
  zstd \
  --noconfirm
RUN rustup update

# Add paru and install AUR pkgs
USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/paru-bin.git --single-branch && \
  cd paru-bin && \
  makepkg -si --noconfirm && \
  cd .. && \
  rm -drf paru-bin && \
  paru -S \
    clipboard \
    espanso-bin \
    --noconfirm

# Cleanup
# RUN userdel -r build && \
#     rm -drf /home/build && \
#     sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
#     sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
#     rm -rf \
#         /tmp/* \
# 	/var/cache/pacman/pkg/*

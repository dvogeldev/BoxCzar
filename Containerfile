FROM docker.io/library/archlinux:base-devel

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="btwiusemacs@fastmail.us>"

COPY extra-packages /
RUN pacman -Syu --needed --noconfirm - < extra-packages
RUN rm /extra-packages
RUN pacman -Scc --noconfirm

RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \      
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree

ARG user=makepkg
RUN useradd --system --create-home $user \
    && echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
USER $user
WORKDIR /home/$user

RUN git clone https://aur.archlinux.org/paru.git
    && cd paru \
    && makepkg -sri --needed --noconfirm \
    && cd \
    $$ rm -rf .cache paru
     

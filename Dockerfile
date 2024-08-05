FROM debian:trixie-20240513-slim

ENV DEBIAN_FRONTEND=noninteractive

# https://snapshot.debian.org/archive/debian/20240515T144351Z/
ARG SNAPSHOT=20240515T144351Z

RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
    : "Enabling snapshot" && \
    sed -i -e '/Types: deb/ a\Snapshot: true' /etc/apt/sources.list.d/debian.sources && \
    : "Enabling cache" && \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache && \
    : "Fetching the snapshot and installing ca-certificates in one command" && \
    apt install --update --snapshot "${SNAPSHOT}" -o Acquire::Check-Valid-Until=false -o Acquire::https::Verify-Peer=false -y ca-certificates && \
    : "Install dependencies" && \
    apt install --snapshot "${SNAPSHOT}" -y \
        curl \
        iproute2 \
        kmod \
        udhcpc \
        wget \
    && \
    : "Clean up for improving reproducibility (optional)" && \
    rm -rf /var/log/* /var/cache/ldconfig/aux-cache

# Kernel

ADD https://github.com/dfinity/sev-snp-deps/releases/download/AMDESE%2Flinux-a38297e3fb012ddfa7ce0321a7e5a8daeb1872b6/linux-image-6.9.0-snp-guest-a38297e-snp-guest-a38297e_6.9.0-1_amd64.deb kernel.deb

RUN dpkg -i kernel.deb && rm kernel.deb

#!/usr/bin/env bash

# shellcheck disable=SC2015

function usage(){
  echo
  echo "Usage: ./vm.sh <hostname>"
  echo
  exit 1
}

set -e
[ -n "$TRACE_VMSH" ] && set -x || true

[ -n "$1" ] && host="$1" || usage

vmdir="/tmp/falter/vm/$host"
mkdir -p "$vmdir"

# to run it in container: cd /vmdir/builter-test ; ./wizard-tester.py node_example.json
cp -avx "$(realpath "$(dirname "$0")")" "$vmdir/builter-test"

wget -nv -O "$vmdir/extract-vmlinux.sh" https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux
chmod +x "$vmdir/extract-vmlinux.sh"

wget -nv -O "$vmdir/kernel.bin" https://firmware.berlin.freifunk.net/unstable/snapshot/tunneldigger/x86/64/openwrt-freifunk-falter-snapshot-x86-64-generic-kernel.bin
# cp firmwares/tunneldigger/x86/64/openwrt-freifunk-falter-snapshot-x86-64-generic-kernel.bin "$vmdir/kernel.bin"
"$vmdir"/extract-vmlinux.sh "$vmdir/kernel.bin" > "$vmdir/vmlinux"

wget -nv -O "$vmdir/rootfs.img.gz" https://firmware.berlin.freifunk.net/unstable/snapshot/tunneldigger/x86/64/openwrt-freifunk-falter-snapshot-x86-64-generic-ext4-rootfs.img.gz
# cp firmwares/tunneldigger/x86/64/openwrt-freifunk-falter-snapshot-x86-64-generic-ext4-rootfs.img.gz "$vmdir/rootfs.img.gz"
gunzip -c "$vmdir/rootfs.img.gz" > "$vmdir/rootfs.img"

# heredoc without variable interpolation
cat << 'EOF' > "$vmdir/vmconfig.json"
{
  "machine-config": {
    "vcpu_count": 1,
    "mem_size_mib": 128,
    "smt": false
  },
  "boot-source": {
    "kernel_image_path": "./vmlinux",
    "boot_args": "ro console=ttyS0 noapic reboot=k panic=1 pci=off nomodules random.trust_cpu=on i8042.noaux"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "./rootfs.img",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "network-interfaces": [
    {
      "host_dev_name": "vmeth0",
      "iface_id": "eth0",
      "guest_mac": "02:fc:00:00:00:06"
    },
    {
      "host_dev_name": "vmeth1",
      "iface_id": "eth1",
      "guest_mac": "02:fc:00:00:00:07"
    }
  ]
}
EOF

# heredoc with variable interpolation
cat << EOF > "$vmdir/entrypoint.sh"
#!/bin/sh

ip tuntap add dev vmeth0 mode tap
ip link set up vmeth0
ip addr add 192.168.42.102/24 dev vmeth0

ip tuntap add dev vmeth1 mode tap
ip link set up vmeth1

brctl addbr wan
brctl addif wan vmeth1
brctl addif wan tap0
ip link set up wan
ip route del \`ip r | grep '24 dev tap0'\`
ip route del \`ip r | grep 'default'\`
ip route add 10.0.2.0/24 dev wan
ip route add default via 10.0.2.2 dev wan

socat -d TCP-LISTEN:22,fork,reuseaddr TCP-CONNECT:192.168.42.1:22 &
socat -d TCP-LISTEN:80,fork,reuseaddr TCP-CONNECT:192.168.42.1:80 &
socat -d TCP-LISTEN:443,fork,reuseaddr TCP-CONNECT:192.168.42.1:443 &

cd /vmdir

while true ; do
  firecracker --no-api --no-seccomp --config-file vmconfig.json
  echo "Restarting VM in 5 seconds..."
  sleep 5
done
EOF
chmod +x "$vmdir/entrypoint.sh"

podman build -t localhost/falter-testing -f - << EOF
FROM alpine:edge

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk upgrade musl
RUN apk add bash openssh-client git vim mtr curl wget tcpdump iproute2 bridge-utils dhclient firecracker socat

RUN apk add python3 py3-pip ca-certificates py3-openssl openssl-dev
RUN pip3 install --break-system-packages selenium pyvirtualdisplay

RUN apk add firefox-esr xvfb dbus-x11 ttf-freefont
RUN ln -s /usr/bin/firefox-esr /usr/bin/firefox
EOF

podman run -it --rm --name="$host" -v "$vmdir:/vmdir:Z" --user=root --userns=keep-id --device=/dev/kvm --device=/dev/net/tun --security-opt="label=disable" --cap-add=NET_ADMIN --cap-add=NET_RAW --network=slirp4netns:mtu=1500 -p 8022:22 -p 8080:80 -p 8443:443 localhost/falter-testing /vmdir/entrypoint.sh

# podman run -t --rm --name="$host" -v "$vmdir:/vmdir:Z" --user=root --userns=keep-id --device=/dev/kvm --device=/dev/net/tun --security-opt="label=disable" --cap-add=NET_ADMIN --cap-add=NET_RAW --network=pasta:-a,10.0.2.0,-n,24,-g,10.0.2.2,--dns-forward,10.0.2.3,-m,1500 docker.io/library/alpine:3.18 /vmdir/entrypoint.sh

echo "Done."

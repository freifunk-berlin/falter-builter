#!/usr/bin/env bash

# shellcheck disable=SC2015

function usage() {
    local v="$1"
    local versions

    echo "usage: test/vm.sh <version>"
    echo
    echo "available falter versions:"
    versions=$(ls out/*/"$v"/x86/64/*-generic-kernel.bin 2>/dev/null)
    if [ -n "$versions" ]; then
        echo $versions | xargs -n1 | cut -d'/' -f 2 | xargs -n1 echo -n " "
        echo
    else
        echo "  n/a"
    fi
    echo
    echo "hint: use build/build.sh to build x86/64 images"
    echo
    exit 1
}

set -o pipefail
set -e
set -x

host="falter-$(xxd -p -l 2 </dev/urandom)"
variant="tunneldigger"

[ -n "$1" ] && version="$1" || usage "$variant" >&2

vmdir="tmp/vm/$host"
mkdir -p "$vmdir"

cp "out/$version/$variant"/x86/64/openwrt-*-generic-kernel.bin "$vmdir/kernel.bin"
test/extract-vmlinux.sh "$vmdir/kernel.bin" >"$vmdir/vmlinux"

cp "out/$version/$variant"/x86/64/openwrt-*-generic-ext4-rootfs.img.gz "$vmdir/rootfs.img.gz"
gunzip -c "$vmdir/rootfs.img.gz" >"$vmdir/rootfs.img"

# heredoc without variable interpolation
cat <<'EOF' >"$vmdir/vmconfig.json"
{
  "machine-config": {
    "vcpu_count": 1,
    "mem_size_mib": 128,
    "smt": true
  },
  "boot-source": {
    "kernel_image_path": "./vmlinux",
    "boot_args": "ro console=ttyS0 reboot=k panic=1 pci=off nomodules random.trust_cpu=on i8042.noaux"
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
cat <<EOF >"$vmdir/entrypoint.sh"
#!/bin/bash

ip tuntap add dev vmeth0 mode tap
ip link set up vmeth0
# ip addr add 192.168.42.102/24 dev vmeth0

# vm's wan interface
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

cd /vmdir

while true ; do
  /vmdir/portfwd.sh vmeth0 &
  firecracker --no-api --no-seccomp --config-file vmconfig.json
  echo "Restarting VM in 5 seconds..."
  sleep 5
done
EOF
chmod +x "$vmdir/entrypoint.sh"

# heredoc without variable interpolation
cat <<'EOF' >"$vmdir/portfwd.sh"
#!/bin/bash

ifname="$1"

ip addr flush $ifname
killall dhclient || true
killall socat || true

# heredoc with variable interpolation
cat << EOF2 > /etc/dhcp/dhclient.conf
interface "$ifname" {
  request subnet-mask, broadcast-address, interface-mtu;
  initial-interval 1;
  backoff-cutoff 2;
}
EOF2

mkdir -p /run/dhcp
udhcpc -b -i $ifname

netmask() {
  local mask=$((0xffffffff << (32 - $1))); shift
  local ip
  for _ in 1 2 3 4; do
    ip=$((mask & 0xff))${ip:+.}$ip
    mask=$((mask >> 8))
  done
  echo "$ip"
}

nth_ip() {
  IFS=". /" read -r i1 i2 i3 i4 mask <<< "$1"
  IFS=" ." read -r m1 m2 m3 m4 <<< "$(netmask "$mask")"
  printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$(($2 + (i4 & m4)))"
}

while true; do
  sleep 1
  localip=$(ip -j a s $ifname | jq -r '.[].addr_info[] | select(.family == "inet") | [.local,.prefixlen|tostring] | join("/")')
  [ -z "$localip" ] || break
done

gw="$(nth_ip "$localip" 1)"
echo "portfwd.sh: router on $ifname is probably $gw"

socat -d -4 TCP-LISTEN:8022,fork,reuseaddr TCP-CONNECT:$gw:22 &
socat -d -4 UDP-LISTEN:8053,fork,reuseaddr UDP-CONNECT:$gw:53 &
socat -d -4 TCP-LISTEN:8080,fork,reuseaddr TCP-CONNECT:$gw:80 &
socat -d -4 TCP-LISTEN:8443,fork,reuseaddr TCP-CONNECT:$gw:443 &
echo "portfwd.sh: available on 127.0.0.1: 8022 (ssh) 8053 (dns) 8080 (http) 8443 (https)"
EOF
chmod +x "$vmdir/portfwd.sh"

# heredoc without variable interpolation
podman build -t localhost/falter-testing -f - <<'EOF'
FROM alpine:edge

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk upgrade musl
RUN apk add bash openssh-client git vim mtr curl wget tcpdump iproute2 bridge-utils firecracker socat jq

RUN apk add python3 py3-pip ca-certificates py3-openssl openssl-dev
RUN pip3 install --break-system-packages selenium pyvirtualdisplay
RUN apk add firefox-esr xvfb dbus-x11 ttf-freefont
RUN ln -s /usr/bin/firefox-esr /usr/bin/firefox
EOF

# to run tests in container: cd /vmdir/builter-test ; ./wizard-tester.py node_example.json
cp -avx "test" "$vmdir/builter-test"

podman run -it --rm --name="$host" -v "$(realpath $vmdir):/vmdir:Z" --user=root --userns=keep-id --device=/dev/kvm --device=/dev/net/tun --security-opt="label=disable" --cap-add=NET_ADMIN --cap-add=NET_RAW --network=slirp4netns -p 8022:8022 -p 8053:8053/udp -p 8080:8080 -p 8443:8443 localhost/falter-testing /vmdir/entrypoint.sh

echo "Done."

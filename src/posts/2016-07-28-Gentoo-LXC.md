---
title: LXC Containers Server with Gentoo, NetworkManager and Systemd
---

Why LXC?
--------

Some things in below list is just my imho and don't take it very serious

 - Kernel level virtualization is better than (hyper-v, vbox, vmware) due control level, no-drivers virtualization, scalability, etc...
 - FreeBSD Jail is actually interesting alternative but portage is more handy as package manager (as for me) and I really needed Linux kernel there.
 - I don't know much about Linux VServer but as for me it's very separated project and I hardly can belong on it.
 - OpenVZ was actually my first Idea but I wanted last btrfs improvements and stuff and last supported kernel there is 2.6.x (they've just made support for 3.10x but now it only close to one distribution, and it is actually weak)
 - LXC (and possibly LXD) feels like future on kernel level virtualization for Linux because it's developed with vanilla kernel and slowly getting most of OpenVZ functionality, nowadays it's really just usable, I'm considering stick with it for now.

Why Gentoo?
-----------

Simply because of maximum level of comfort and flexibility, another system I can suggest there is CoreOS (which is also based on Gentoo) however being Gentoo dev my choice is obvious.

 Most of tutorials shows bridge configuration based on openrc's /etc/conf.d/net services but it's not any harder and even simpler with `nmcli`

 basically (example from [freedesktop.org](https://people.freedesktop.org/~lkundrak/nm-docs/nmcli-examples.html)):

``` shell
$ nmcli con add type bridge con-name TowerBridge ifname TowerBridge
$ nmcli con add type ethernet con-name br-slave-1 ifname ens3 master TowerBridge
$ nmcli con add type ethernet con-name br-slave-2 ifname ens4 master TowerBridge
$ nmcli con modify TowerBridge bridge.stp no
```

Anything LXC specific could be done via [Gentoo Wiki Tutorial](https://wiki.gentoo.org/wiki/LXC#Host_setup)

Some basic container config with own network will look alike this:

``` json
lxc.network.type = veth
lxc.network.link = lxbridge
lxc.network.flags = up
lxc.network.ipv4 = 192.168.3.146/24
lxc.network.ipv4.gateway = 192.168.3.254

lxc.group = onboot
lxc.start.auto = 1
lxc.start.delay = 5

lxc.rootfs = /srv/C
lxc.rootfs.backend = dir
### lxc-gentoo template stuff starts here
# sets container architecture
# If desired architecture != amd64 or x86, then we leave it unset as
# LXC does not oficially support anything other than x86 or amd64.
lxc.arch = amd64

# set the hostname
lxc.utsname = Cloyster
lxc.tty = 1

#container set with shared portage
lxc.mount.entry=/usr/portage usr/portage none ro,bind 0 0
lxc.mount.entry=/usr/portage/distfiles usr/portage/distfiles none rw,bind 0 0
#If you use eix, you should uncomment this
#lxc.mount.entry=/var/cache/eix var/cache/eix none ro,bind 0 0

lxc.include = /usr/share/lxc/config/gentoo.common.conf
```

working with containers using on-host lxc commands is pretty simple

``` shell
lxc-start -n C
lxc-console -n C
```

default gentoo container password is `toor`

inside basic Gentoo lxc container there is OpenRC so very basic veth config will follow:

``` shell
rc_keyword="-stop"

#config_eth0="dhcp"
config_eth0="192.168.3.146 netmask 255.255.255.0 brd 192.168.0.254"
routes_eth0="default via 192.168.3.254"
dns_servers_eth0="192.168.3.254 192.168.3..."
```

don't forget to set it on autostart

``` shell
rc-config add net.eth0
```

I had problems with running it on system start so I was forced to write some systemd service to automate it

``` shell
[Unit]
Description=LXCAutostart
After=network.target
After=dbus.service
After=iscsid.service
After=apparmor.service
After=local-fs.target
After=remote-fs.target
After=lxc.service
After=lxcfs.service
After=NetworkManager.service
After=dnsmasq.service
After=nfs-client.target

[Service]
Type=simple
RemainAfterExit=yes
ExecStart=/usr/bin/lxc-autostart -g onboot
TimeoutStopSec=1

[Install]
WantedBy=multi-user.target
```

put it into `/etc/systemd/system` and `systemctl enable` it

There the basic setup is done.

Interesting article to [Run Accelerated GUI apps in LXC containers](https://www.flockport.com/run-gui-apps-in-lxc-containers/)

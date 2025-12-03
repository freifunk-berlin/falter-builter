## Overall Project Structure and Falter Repositories
The [Falter project](https://github.com/freifunk-berlin/falter-packages) builds a modern OpenWrt-based firmware for Freifunk Berlin. We split our code on different repositories. For the beginning there are two main repositories you should know:

+ **[packages](https://github.com/freifunk-berlin/falter-packages/)**: This repo holds the source code for an OpenWrt package feed. All falter specific packets reside there, regardless if they are luci-apps or just command-line-apps. *Everything* should be bundled as a package. If you want to file an issue or fix a bug you probably want to go here.
+ **[builter](https://github.com/freifunk-berlin/falter-builter)**: The builter assembles Freifunk images from the OpenWrt-imagebuilder and the pre-compiled package feed from [buildbot](https://buildbot.berlin.freifunk.net/). If you want to include a new app into falter, you'd need to add it to the packagelists defined here.

# falter-builter

This script packages falter-firmware from openwrt-imagebuilder and falter-feed. In comparison to the old buildsystem, it is almost insanely fast.

## Utilisation

The script takes four positional arguments. You can add env variables as well, have a look at the helptext.

```sh
build/build.sh <version> <target> <profile> [<destination>]
```

`version` takes the falter-version you would like to build. This maps to the feed-directories avaiable at [buildbot](https://firmware.berlin.freifunk.net/feed/).

`Destination` will default to `out/<version>/<target>/<subtarget>/`

You can leave `version`, `profile` or `target` away to get a prefilled helptext with all available options.

If you like to build only one specific router-profile, you *must* give all the arguments before.

## Quickstart: build your own image

Lets assume you'd like to build a stable-release-tunneldigger-image for your Genexis Pulse EX400 router. To achieve that, you should invoke the buildscript in that way:

```sh
build/build.sh 1.5.0 ramips/mt7621 genexis_pulse-ex400
```

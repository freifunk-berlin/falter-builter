# falter-builter

This script packages falter-firmware from openwrt-imagebuilder and falter-feed. In comparison to the old buildsystem, it is almost insanely fast.

## Utilisation

The script takes five positional arguments.

```
./build_falter [-p packageset] [-v version] [-t target] [-s subtarget] [-r router]
```

The parameters for packageset, version and target are mandatory. The other ones optional

If you give packageset, release and no subtarget, it will generate all subtargets of that certain target and so on.

If you like to build only one specific router-profile, you *must* give all the arguments before. 

`version` takes the falter-version you would like to build. This maps to the feed-directories avaiable at [buildbot](https://firmware.berlin.freifunk.net/feed/).

After the buildprocess finished, you will find the images in `firmwares/`.


## Quickstart: build your own image

Lets assume you'd like to build a stable-release-tunneldigger-image for your GL-AR150 router. To achieve that, you should invoke the buildscript in that way:

```
./build_falter -p packageset/19.07/tunneldigger.txt -v 1.1.1 ath79 -s generic -r glinet_gl-ar150
```
If you are more comfortable in memorizing it that way, you can use long arguments:
```
./build_falter --packageset packageset/19.07/tunneldigger.txt --version 1.1.1 --target ath79 --sub-target generic -router glinet_gl-ar150
```

### Find your routers profile

If you don't know the profile name for your router, you should use `-l` to find it. That option will show you a list of all routers with there profiles. Pick the profile-name there and give it to the script with the `-r` parameter.

```
./build_falter -p packageset/19.07/tunneldigger.txt -v 1.1.1-snapshot -t ath79 -s generic -l
```
In the router list you will find something similar like that:
```
glinet_gl-ar150:
    GL.iNet GL-AR150
    SupportedDevices: glinet,gl-ar150 gl-ar150
```
The profile name is at the first line. Omit the colon:
```
./build_falter -p packageset/19.07/tunneldigger.txt -v 1.1.1-snapshot -t ath79 -s generic -r glinet_gl-ar150
```

## Use builter with buildbot

For the image generation with buildbot, builter should be invoked like this:
```
./build_falter -p all -v <release> -t <target>
```
The argument `all` will signalise builter to generate all three flavours of images. In `firmwares/` the images get sorted by package-list. Below the packagelist-directorys, the regular hirachy $TARGET/$SUBTARGET applies.

CAUTION: Argument `all` will only work if at least release *and* target are specified.

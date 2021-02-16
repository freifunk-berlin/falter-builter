# falter-builter

This script packages falter-firmware from openwrt-imagebuilder and falter-feed. In comparison to the old buildsystem, it is almost insanely fast.

## Utilisation

The script takes five positional arguments.

```
./build_falter [-p packageset] [-v version] [-t target] [-s subtarget] [-r router]
```

The packageset is mandatory, the latter ones optional.
If you just give a packageset, all releases and all targets get built.

If you give packageset, release and no target, it will generate all targets of that certain release and so on.

If you like to build only one specific router-profile, you *must* give all the arguments before. 

`version` has currently these valid values: `19.07`, '21.02' and `snapshot`.

After the buildprocess finished, you will find the images in `firmwares/`.


## Quickstart: build your own image

Lets assume you'd like to build a stable-release-tunneldigger-image for your GL-AR150 router. To achieve
that, you should invoke the buildscript in that way:

```
./build_falter -p packageset/19.07/tunneldigger.txt -v 19.07 -t ath79 -s generic -r glinet_gl-ar150
```
If you are more comfortable in memorizing it that way, you can also use long arguments:
```
./build_falter --packageset packageset/19.07/tunneldigger.txt --version 19.07 --target ath79 --sub-target generic -router glinet_gl-ar150
```

## Use builter with buildbot

For the image generation with buildbot, builter should be invoked like this:
```
./build_falter -p all -v <release> -t <target>
```
The argument `all` will signalise builter to generate all three flavours of images. In `firmwares/` the images get sorted by package-list. Below the packagelist-directorys, the regular hirachy $TARGET/$SUBTARGET applies.

CAUTION: Argument `all` will only work if at least release *and* target are specified.

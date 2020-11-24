# falter-builter

This script packages falter-firmware from openwrt-imagebuilder and falter-feed. In comparison to the old buildsystem, thats almost insanely fast.

## utilisation

The script takes five positional arguments.

```
./build_falter [packageset] <release> <target> <subtarget> <profile>
```

The first argument is mandatory, the latter ones optional.
If you just give a packageset, all releases and all targets get built.

If you give packageset, release and no target, it will generate all targets of that certain release and so on.

If you like to build only one specific router-profile, you *must* give all the arguments before. 

`release` takes currently two values: `19.07` and `snapshot`. 

After the buildprocess finished, you will find the images in `firmwares/`.


## build your own image

Lets assume you'd like to build a stable-release-tunneldigger-image for your GL-AR150 router. To achieve
that, you should invoke the buildscript in that way:

```
./build_falter packageset/tunneldigger.txt 19.07 ath79 generic glinet_gl-ar150
```

## use builter with buildbot

For the image generation with buildbot, builter should be invoked like this:
```
./build_falter all <release> <target>
```
The argument `all` will signalise builter to generate all three flavours of images. In `firmwares/` the images get sorted by package-list. Below the packagelist-directorys, the regular hirachy $TARGET/$SUBTARGET applies.

CAUTION: Argument `all` will only work if at least release *and* target are specified.

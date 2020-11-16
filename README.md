# falter-builter

This script packages falter-firmware from openwrt-imagebuilder and falter-feed. In comparison to the old buildsystem, thats almost insanely fast.

## utilisation

The script takes three positional arguments.

```
./build [packageset] <release> <target>
```

The first argument is mandatory, the latter optional.
If you just give a packageset, all releases and all targets get built.

If you give packageset, release and no target, it will generate all targets of that certain release and so on.

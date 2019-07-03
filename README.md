# Third Person Shooter Demo

![Screenshot of TPS demo](screenshot.png)

Third person shooter demo made using [Godot Engine](https://godotengine.org) 3.1.

**Note:** Until Godot 3.1-stable is released, you need a recent build from Godot's
*master* branch to run this demo. You can build the engine from source, or use one
of @Calinou's [nightly builds](https://hugo.pro/projects/godot-builds).

**Note 2:** The repository is big and asset importing not well optimized yet, so expect
a high CPU and RAM load when opening the project for the first time.

## Git LFS

This demo uses [Git LFS](https://git-lfs.github.com/) to store the heaviest assets.

You need to install the Git LFS extension on your system, so that Git can fetch the
assets from the LFS repository. It should happen automatically when using the usual
Git commands.

If you cloned this Git repository *before* installing Git LFS, or if for any other
reason you get errors importing .dae files in Godot, try to run those commands
manually:

```text
git lfs install
git lfs fetch
git checkout master
```

**Note:** The above steps are very important, if you do not have the LFS assets
checked out, you will not be able to run this demo.
You can confirm that you properly checked out the assets by verifying e.g. that
your ``level/geometry/demolevel.dae`` file is over 300 MBs.

## Running

You need [Godot Engine](https://godotengine.org) in version 3.1 or later to run
this demo project. Download the latest stable version [from the website](https://godotengine.org/download/)
or [build it from source](https://github.com/godotengine/godot).

Once you have cloned this repository and made sure that all LFS assets were
checked out, you should open the project in the Godot editor to trigger the
import of all assets.

## License

See [LICENSE.txt](/LICENSE.txt) for details.

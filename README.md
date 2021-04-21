# Third Person Shooter Demo

Third person shooter demo made using [Godot Engine](https://godotengine.org).

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/678

![Screenshot of TPS demo](screenshots/screenshot.png)

## Godot versions

- The [`master`](https://github.com/godotengine/tps-demo) branch is compatible with the latest stable Godot version (currently 3.3.x).
- If you are using an older version of Godot, use the appropriate branch for your Godot version:

  - [`3.2`](https://github.com/godotengine/tps-demo/tree/3.2) branch
  for Godot 3.2.2 or 3.2.3.
  - [`3.2.1`](https://github.com/godotengine/tps-demo/tree/3.2.1) branch
  for Godot 3.2.0 or 3.2.1.
  - [***`3.1`***](https://github.com/godotengine/tps-demo/tree/3.1) branch
  for Godot 3.1.x.

**Note:** The repository is big and asset importing not well optimized yet, so expect
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

You need [Godot Engine](https://godotengine.org) to run this demo project.
Download the latest stable version [from the website](https://godotengine.org/download/),
or [build it from source](https://github.com/godotengine/godot).

Once you have cloned this repository and made sure that all LFS assets were
checked out, you should open the project in the Godot editor to trigger the
import of all assets.

## Useful links

- [Main website](https://godotengine.org)
- [Source code](https://github.com/godotengine/godot)
- [Documentation](http://docs.godotengine.org)
- [Community hub](https://godotengine.org/community)
- [Other demos](https://github.com/godotengine/godot-demo-projects)

## License

See [LICENSE.md](LICENSE.md) for details.

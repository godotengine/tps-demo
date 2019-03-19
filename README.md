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

If you cloned this Git repository *before* installing Git LFS, you will have to fetch
the assets manually the first time:

```text
git lfs fetch
git checkout master
```

Note that you cannot use the Download ZIP link provided by GitHub;
[it contains only the pointers](https://github.com/git-lfs/git-lfs/issues/903) to the
to the files, not the files themselves. This results in corruption errors when opening
the project in Godot. Use your Git client to create a proper clone instead.

## License

See [LICENSE.txt](/LICENSE.txt) for details.

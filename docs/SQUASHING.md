# How do I "squash" my commits?

On your command line you'll want to do:

```
git rebase -i origin/develop
```

This says to rebase your work off of develop. If you use an editor like Sublime Text, you'll want to [be sure your editor doesn't close without a response](https://gist.github.com/geekmanager/9939cf67598efd409bc7).

From here, you'll see something like:

```
pick f48d47c The first commit I did
pick fd4e046 The second commit I did
```

You'll want to change everything after your first commit from `pick` to `squash`. This tells git you want to squash these commits into the first one.

From here, you'll get an editor that will let you change the commit messages.

```
# This is a combination of 2 commits.
# The first commit's message is:
The first commit I did

# This is the 2nd commit message:

The second commit I did
```

You'll want to remove or comment out everything except for the first message, which you can edit to be a more complete summary of your changes.

To finish, you'll force push this new commit with the following command:

```
git push origin [my-feature-branch] --force-with-lease
```

The `--force-with-lease` flag will refuse to update a branch if someone else has updated it upstream, making your force push a little safer.

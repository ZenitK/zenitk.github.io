---
layout: post
title: 'Stage Code Hunks In GIT CLI'
tags: [GIT]
featured_image_thumbnail: /assets/images/posts/2023/git/Git-Logo-2Color.png
description: 'Stage Code Hunks In GIT CLI'
category: GIT
---

Let's say you've made way too many changes that you don't want to place in the same commit, and these changes are mixed up in the same file. The GIT CLI supports adding of partial hunks interactively. 

```shell
git add -p
# or
git add --patch
```

For each hunk, you'll be presented with a set of options:

- `y` - apply this hunk
- `n` - do not apply this hunk
- `a` - apply this and all remaining hunks
- `d` - do not apply this hunk or any of the remaining hunks
- `g` - select a hunk to go to
- `/` - search for a hunk matching the given regex
- `j` - leave this hunk undecided and see the next undecided hunk
- `J` - leave this hunk undecided and see the next hunk
- `k` - leave this hunk undecided and see the previous undecided hunk
- `s` - split the current hunk into smaller hunks
- `e` - manually edit the current hunk
- `?` - print the help

The GIT documentation can be found [here](https://git-scm.com/docs/git-add#Documentation/git-add.txt--p)
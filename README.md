# Git Timeline

Allows bulk modification of the commit dates of a repository, changing the history of a repository.

## Usage

```bash
./git-timeline.bash demo
./git-timeline.bash history
```

The file `HISTORY` can then be editted to change the times of the files to other dates. _The day of the week does not need to be changed_

```text
491c217 Fri Jan 3 20:58:35 2020 -0500 -> 71ecebc Wed Jan 1 20:58:35 2020 -0500
491c217 Fri Jan 3 20:58:35 2020 -0500
4c1a042 Fri Jan 3 20:58:34 2020 -0500
e9561ee Fri Jan 3 20:58:34 2020 -0500
30e8029 Fri Jan 3 20:58:34 2020 -0500
d428d9c Fri Jan 3 20:58:34 2020 -0500
5080409 Fri Jan 3 20:58:34 2020 -0500
046c105 Fri Jan 3 20:58:34 2020 -0500
d6aa27a Fri Jan 3 20:58:34 2020 -0500
6d14846 Fri Jan 3 20:58:33 2020 -0500
8911276 Fri Jan 3 20:58:33 2020 -0500
858d0fe Fri Jan 3 20:58:33 2020 -0500
55c7497 Fri Jan 3 20:58:33 2020 -0500
477351c Fri Jan 3 20:58:33 2020 -0500
a2b89ab Fri Jan 3 20:58:33 2020 -0500
c76d838 Fri Jan 3 20:58:33 2020 -0500
```

After the file has been changed, you can run this following to apply:

```bash
./git-timeline.bash apply
```

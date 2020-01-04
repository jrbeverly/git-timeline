#!/bin/bash

fresh () {
    mkdir -p fresh/
    cd fresh/

    # Initialize
    git init
    echo "0" > FILE
    git add FILE
    git commit -m 'Initial commit'

    # Set the items
    for i in {1..15}
    do
        echo "$i times" > FILE
        git add FILE
        git commit -m "Changed to $i"
        sleep 2s
    done
}

demo () {
    rm -rf demo/
    cp -r fresh/ demo/
}

history () {
    cd demo/
    commit_file=
    git log --oneline --pretty=format:"%ad|%s" > "../COMMITS"
    awk '{print NR-1 "|" $s}' "../COMMITS" > "../HISTORY" 
    sed -i '1d;$d' "../HISTORY"
    touch "../LATEST"
    touch "../FIRST"
}

show () {
    cd demo/
    git log --pretty=format:"%h%x09%an%x09%ad%x09%s"
}

git-rebase-custom() {
    GIT_SEQUENCE_EDITOR="sed -i -ze 's/^pick/e/'" git rebase "HEAD~$1^" -i
    GIT_COMMITTER_DATE="$2" git commit --amend --no-edit --date="$2"
    GIT_SEQUENCE_EDITOR=touch git rebase --continue
}

apply () {
    cd demo/
    commit_latest "$(cat ../LATEST)"
    while read p; do
        counter=$(echo "$p" | cut -d'|' -f1)
        datetime=$(echo "$p" | cut -d'|' -f2)
        msg=$(echo "$p" | cut -d'|' -f3)

        git-rebase-custom "$counter" "$datetime"
    done <"../HISTORY"
    commit_first "$(cat ../FIRST)"
}

commit_latest () {
    datetime="$@"
    GIT_COMMITTER_DATE="$datetime" git commit --amend --no-edit --date="$datetime"
}

commit_first () {
    datetime="$@"
    GIT_SEQUENCE_EDITOR="sed -i -ze 's/^pick/e/'" git rebase -i --root
    GIT_COMMITTER_DATE="$datetime" git commit --amend --no-edit --date="$datetime"
    GIT_SEQUENCE_EDITOR=touch git rebase --continue
}

cycle () {
    ( demo )
    ( apply )
    ( show )
}

$@
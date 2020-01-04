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
    git log --oneline --pretty=format:"%ad|%s" | awk '{print NR-1 "|" $s}' > "../COMMITS"
    tac "../COMMITS" > "../HISTORY"
    sed -i '1d;$d' "../HISTORY"
    touch "../LATEST"
    touch "../FIRST"
}

show () {
    cd demo/
    git log --pretty=fuller
}

apply () {
    cd demo/
    commit_first "$(cat ../FIRST)"
    while read p; do
        counter=$(echo "$p" | cut -d'|' -f1)
        datetime=$(echo "$p" | cut -d'|' -f2)
        msg=$(echo "$p" | cut -d'|' -f3)

        git-rebase-custom "$counter" "$datetime"
    done <"../HISTORY"
    commit_latest "$(cat ../LATEST)"
}

git-rebase-custom() {
    datetime="$2"
    (
        export GIT_COMMITTER_DATE="$datetime"

        GIT_SEQUENCE_EDITOR="sed -i -ze 's/^pick/e/'" git rebase "HEAD~$1^" -i
        git commit --amend --no-edit --date="$datetime"
        GIT_SEQUENCE_EDITOR=touch git rebase --continue

        unset GIT_COMMITTER_DATE
    )
}


commit_latest () {
    datetime="$@"
    (
        export GIT_COMMITTER_DATE="$datetime"
        git commit --amend --no-edit --date="$datetime"

        unset GIT_COMMITTER_DATE
    )
}

commit_first () {
    datetime="$@"
    (
        export GIT_COMMITTER_DATE="$datetime"

        GIT_SEQUENCE_EDITOR="sed -i -ze 's/^pick/e/'" git rebase -i --root
        git commit --amend --no-edit --date="$datetime"
        GIT_SEQUENCE_EDITOR=touch git rebase --continue

        unset GIT_COMMITTER_DATE
    )
}

cycle () {
    ( demo )
    ( apply )
    ( show )
}

$@
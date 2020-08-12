#!/bin/bash

fuzzy () {
    mkdir -p fuzzy/
    cd fuzzy/
    days=${1:-731}
    daily=${2:-2}

    # Initialize
    git init
    echo "0" > FILE
    git add FILE
    git commit -m 'Initial commit'

    export INITIAL_DATE='2019-01-01 19:50:42 -0400'
    for i in $(seq 1 $days)
    do
        commits=$((RANDOM % $daily))
        for d in $(seq 1 $commits)
        do
            hour=$((18 + RANDOM % 5))
            minute=$((RANDOM % 60))
            second=$((RANDOM % 60))
            NEXT_DATE=$(date "+%Y-%m-%d ${hour}:${minute}:${second} %z" -d "$INITIAL_DATE + $i day")

            echo "$i:$d times" > FILE
            git add FILE
            set GIT_COMMITTER_DATE="${NEXT_DATE}"
            set GIT_AUTHOR_DATE="${NEXT_DATE}"
            GIT_AUTHOR_DATE="${NEXT_DATE}" GIT_COMMITTER_DATE="${NEXT_DATE}" git commit -m "[peon] work $i:$d"
        done
    done
}

clone () {
    mkdir -p clone/
    cd clone/

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

working () {
    rm -rf working/
    cp -r clone/ working/
}

history () {
    cd working/
    commit_file=
    git log --oneline --pretty=format:"%ad|%s" | awk '{print NR-1 "|" $s}' > "../COMMITS"
    tac "../COMMITS" > "../HISTORY"
    sed -i '1d;$d' "../HISTORY"
    touch "../LATEST"
    touch "../FIRST"
}

show () {
    cd working/
    git log --pretty=fuller
}

apply () {
    cd working/
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
    ( working )
    ( apply )
    ( show )
}

$@

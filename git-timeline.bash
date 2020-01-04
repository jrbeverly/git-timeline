#!/bin/bash

demo () {
    mkdir -p demo/
    cd demo/

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
    done
}

history () {
    cd demo/
    git log --oneline --pretty=format:"%h %ad" > ../HISTORY
}

git-rebase-custom() {
    GIT_SEQUENCE_EDITOR="sed -i -ze 's/^pick/e/'" git rebase "$1^" -i
    GIT_COMMITTER_DATE="$2" git commit --amend --no-edit --date "$2"
}

apply () {
    cd demo/
    while read p; do
        commit=$(echo "$p" | cut -d' ' -f1)
        datetime="${p#* }"
        echo $commit
        echo $datetime
        git-rebase-custom "$commit" "$datetime"
    done <../HISTORY
}

$@
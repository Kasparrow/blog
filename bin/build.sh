#!/bin/bash

set -e

if [[ -d './tmp' ]]; then
        rm -rf './tmp'
fi

mkdir tmp
mkdir tmp/articles
cp -rf './src/css' './tmp/css'
cp -rf './src/fonts' './tmp/fonts'
cp -rf './src/img' './tmp/img'
touch ./tmp/entries

find ./src/articles -type f -print0 | xargs -0 ls -t | sort -r | while read article; do
        title=`sed '1q;d' $article`
        date=`sed -E '2q;d;' $article | cut -c 1-10`
        slug=`echo $title |
                iconv -t ascii//TRANSLIT |
                sed -r s/[^a-zA-Z0-9]+/-/g |
                sed -r s/^-+\|-+$//g |
                tr A-Z a-z`
        dest="./tmp/articles/$slug.html"

        cat ./src/templates/article.html |
                sed "s~TITLE~$title~" |
                sed "s~DATE~$date~" |
                sed "s~CONTENT~$(tail -n +3 $article | tr -d '\n')~" > $dest

        summary=`tail -n +3 $article |
                        sed -E "s/<.+>//;/^$/d" |
                        tr -d '\n' |
                        cut -c 1-300`
        cat ./src/templates/article_entry.html |
                sed "s~TITLE~$title~" |
                sed "s~URL~./articles/$slug.html~" |
                sed "s~DATE~$date~" |
                sed "s~CONTENT~$summary~" >> ./tmp/entries
done

cat ./src/templates/page.html |
        sed "s~CONTENT~$(cat ./tmp/entries | tr -d '\n')~" > ./tmp/index.html
rm ./tmp/entries

for page in ./src/pages/*; do
        cat ./src/templates/page.html |
                sed "s~CONTENT~$(cat $page | tr -d '\n')~" > "./tmp/$(basename $page)"
done


if [[ -d './release' ]]; then
        rm -rf './release'
fi

mv tmp release

echo "Build success !"

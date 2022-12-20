#!/bin/bash

filename="./src/articles/article_$(printf "%06d" $(ls ./src/articles | wc -l)).html"

echo "<TITLE>" > $filename
echo "<DATE>" >> $filename
echo "<p>" >> $filename
echo "</p>" >> $filename

echo $filename

#!/bin/bash

./gradlew asciidoctor
git checkout gh-pages
cp -r target/asciidoc/* .
rm -r target


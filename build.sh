#!/bin/bash

./gradlew asciidoctor
cp -r target/asciidoc/* .
rm -r target
git checkout gh-pages


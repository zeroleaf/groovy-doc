#!/bin/bash

# TODO 如果原有的文件在新版本中被删除了, 该脚本不会删除这些文件

function copyIfChange() {
    diffCount=$(diff $1 $2 | wc -l)
    # 4 是因为每次 build 都是更新时间, diff 之后的输出共有4行
    if [ $diffCount -gt 4 ]; then
        cp $1 $2
    fi
}

targetDir="target/asciidoc/"

./gradlew asciidoctor
git checkout gh-pages

# 如果有新增的文件夹, 则创建
folders=$(find $targetDir -type d | sed "s/target\/asciidoc\/*//")
for folder in $folders
do
    if [ ! -z $folder ] && [ ! -d $folder ]; then
        mkdir -p $folder
    fi
done

# 此次构建生成的与原始版本对比, 复制新文件, 与修改过的文件.
nfiles=$(find $targetDir -type  f | sed "s/target\/asciidoc\/*//")
for nfile in $nfiles
do
    if [ ! -f $nfile ]; then
        cp "$targetDir$nfile" "$nfile"
    else
        copyIfChange "$targetDir$nfile" "$nfile"
    fi
done

rm -r target

#!/bin/bash
echo "Enter post title: "
read _title
echo "Tags: "
read _tags
_dateString=$(date +'%F')
_dateTimeString=$(date +'%F %T %z')
_postFolder=./_posts
_frontMatter=$"---
layout: post
title: $_title
date: $_dateTimeString
tags: $_tags
---"
_lowercaseTitle=$(echo "$_title" | tr '[:upper:]' '[:lower:]')
_formattedTitle=${_lowercaseTitle// /-}
_newFile="$_dateString-$_formattedTitle.markdown"
echo "$_frontMatter" > $_postFolder/$_newFile

vim $_postFolder/$_newFile

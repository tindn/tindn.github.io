---
layout: post
title: Create new jekyll post script
date: 2016-08-20 11:17:23 -0500
tags: jekyll bash
---
Programmers are lazy, and as a programmer, I feel too lazy to create new Jekyll posts, mostly too lazy
to type the date and the front matter. So I tried to create a bash script to do so. However, with my 
limited knowledge of bash, I was taking way too long. A quick googling lead me to this [post](http://helenvholmes.com/notes/creating-new-jekyll-posts-with-bash/){:target="_blank"}.


I have modified the script I found here to make it what I want. Very minimal modification. As it turned out, I was 
overcomplicating things. Below is my script.


    #!/bin/bash¬
    echo "Enter post title: "¬
    read _title¬
    echo "Tags: "¬
    read _tags¬
    _dateString=$(date +'%F')¬
    _dateTimeString=$(date +'%F %T %z')¬
    _postFolder=./_posts¬
    _frontMatter=$"---¬
		layout: post¬
		title: $_title¬
		date: $_dateTimeString¬
		tags: $_tags¬
	---"¬
    _lowercaseTitle=$(echo "$_title" | tr '[:upper:]' '[:lower:]')¬
    _formattedTitle=${_lowercaseTitle// /-}¬
    _newFile="$_dateString-$_formattedTitle.markdown"¬
    echo "$_frontMatter" > $_postFolder/$_newFile¬
 ¬
    vim $_postFolder/$_newFile¬

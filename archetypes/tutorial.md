---
title: "{{ replace .Name "-" " " | title }}"
description: "一句话介绍这篇教程"
date: {{ .Date }}
image:                  # 封面图，如 cover.jpg（放到本教程目录里）
math: true             # 用到数学公式就设为 true
categories: [教程]      # 分类，可改成别的
tags:
    - 
draft: true             # 发布时把 true 改成 false
---

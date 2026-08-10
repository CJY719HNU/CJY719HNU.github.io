---
title: "{{ replace .Name "-" " " | title }}"
description: "一句话介绍这个项目"
date: {{ .Date }}
image:                  # 封面图，如 cover.jpg（放到本项目目录里）
tags:
    - 
draft: true             # 发布时把 true 改成 false
# 分类不用写：本分区会自动带上 categories: [项目]
# 想加别的分类（如 机器人），在这里补上即可
---

#!/bin/bash
# 飞书(Lark)导出的 Markdown → Hugo/KaTeX 兼容转换
#
# 用法：
#   ./tools/feishu2hugo.sh content/tutorials/xxx/index.md [更多文件...]
#
# 修复飞书 md 与 Hugo 的兼容问题：
#   1. $\begin{equation}...\end{equation}$  →  $$ ... $$   （KaTeX 显示公式）
#   2. $\begin{gather}...\end{gather}$      →  $$ ... $$   （gather 换成 gathered）
#   3. \notag                              →  删除          （gathered 里是多余的行号控制）
#   4. 飞书转义的点 \.                     →  .             （纯排版清理，不影响 \\ 换行和数学）
#   5. 公式内部夹的空行                    →  删除          （防止 $$...$$ 被断成两段导致 KaTeX 配对失败）
#   6. 检测到数学内容 → 自动把 front matter 的 math: 设为 true
#
# 注意：
#   - 飞书文档里的图片（图片和附件/ 文件夹）需要连同文章一起拷贝到文章目录下，
#     本脚本不处理图片搬运。
#   - 飞书偶尔把行内公式断到两行（$... 换行 再闭合 $），KaTeX 通常能跨行渲染，
#     但转换后建议在浏览器里检查公式是否正常显示。

set -euo pipefail

for f in "$@"; do
    if [ ! -f "$f" ]; then
        echo "跳过：找不到文件 $f"
        continue
    fi

    # 1~3. 数学环境转换（顺序很重要：先 gather→gathered，再处理 $ 包裹）
    sed -i \
        -e 's/\\begin{gather}/\\begin{gathered}/g' \
        -e 's/\\end{gather}/\\end{gathered}/g' \
        -e 's/\$\\begin{equation}/$$/g' \
        -e 's/\\end{equation}//g' \
        -e 's/\$\\begin{gathered}/$$/g' \
        -e 's/\\end{gathered}\$/$$/g' \
        -e 's/\\notag//g' \
        "$f"

    # 飞书有时把闭合的 $ 放在 \end{equation} 的下一行，单独补成 $$
    sed -i 's/^\$$/$$/' "$f"

    # 4. 清理飞书转义点：\. → .（用负向断言，不误伤 \\ 换行和数学里的 \.）
    perl -i -pe 's/(?<!\\)\\\././g' "$f"

    # 5. 飞书公式里常夹空行，会把 $$...$$ 断成两个 Markdown 段落，
    #    KaTeX 按段落找 $$ 配对找不到闭合，公式就渲染失败。
    #    这里删掉"独占 $$ 定界的完整块"内部的空行（畸形的一行式/嵌入式 $$ 不碰）。
    _n=$(grep -c '^[[:space:]]*\$\$[[:space:]]*$' "$f")
    if [ $(( _n % 2 )) -eq 0 ]; then
        awk '/^[[:space:]]*\$\$[[:space:]]*$/ { if (inm) inm=0; else inm=1; print; next }
             inm && /^[[:space:]]*$/ { next }
             { print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    else
        echo "⚠️  $f 的 $$ 行数是奇数(${_n})，跳过公式内空行清理，请手动检查定界符"
    fi

    # 6. 有数学内容就确保开启 math 渲染
    if grep -qE '\$\$|\\begin\{' "$f"; then
        sed -i 's/^math: *$/math: true/' "$f"
    fi

    echo "✅ 已转换: $f"
done

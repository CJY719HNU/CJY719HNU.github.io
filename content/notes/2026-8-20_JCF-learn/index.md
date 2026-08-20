---
title: 现代控制理论学习笔记（1）：若尔当标准型
description: 若尔当标准型学习笔记
date: 2026-08-20T23:27:40+08:00
image:                  # 封面图，如 cover.jpg（放到本笔记目录里）
categories: [笔记]      # 分类，可改成别的（如 嵌入式）
math: true  
tags:
    - 现代控制理论
    - 线性代数
draft: flase             # 发布时把 true 改成 false
---

## 为什么需要若尔当标准型
$n\times n$ 矩阵对角化需要$n$个线性无关的特征向量。若特征值有重根会导致特征向量数量不足，矩阵无法对角化。于是使用**若尔当块**拼出一个最接近对角的矩阵。

## 若尔当块
对于重根特征值$\lambda$，若尔当块对角线元素为$\lambda$，紧挨着主对角线上方全为$1$，其余为$0$。


$$
J_2(\lambda) = \begin{bmatrix} \lambda & 1 \\ 0 & \lambda \end{bmatrix}，J_3(\lambda) = \begin{bmatrix} \lambda & 1 &0\\ 0 & \lambda & 1\\ 0 & 0 & \lambda \end{bmatrix}……
$$


## 求若尔当标准型步骤
1. 求特征值及其**代数重数**$m$。
例：$(\lambda-1)^2(\lambda-2)=0$，$\lambda=1$ 代数重数$m=2$。

2. 计算**零化度序列**$d_k$
定义：
$$
d_k=\mathrm{nullity}(A-\lambda I)^k = n-\mathrm{rank}\big((A-\lambda I)^k\big)
$$
边界条件：令$d_0=0$，一直计算直到$d_k=m$为止。

> 关于零化度序列的下文会有更详细讲解。

3. 计算大小为$j$的若尔当块个数$c_j$
$$
c_j=2d_j-d_{j-1}-d_{j+1}
$$
他的原始公式展开为
$$
c_j=(d_j-d_{j-1})-(d_{j+1}-d_j)=\Delta_j-\Delta_{j+1}
$$
> $\Delta_k = d_k-d_{k-1}$，这个等式后面会讲。

得到各个大小若尔当块数量后就可以写出若尔当矩阵$J$；书写惯例：**左上角放高重次块，右下角放低重次块**。

## 零化度序列
设$A$为$n\times n$矩阵，取某一个特征值$\lambda$，记
$$
N = A-\lambda I
$$
$N$是对应这个特征值的幂零部分。

零化度序列$d_k$定义：
对任意非负整数$k$，考虑齐次方程组
$
N^k \boldsymbol{X} = \boldsymbol{0}
$
（$\boldsymbol{X}$为矩阵自变量）。
$N^k$表示$N$自乘$k$次（规定$N^0=I$），方程组全部解向量构成线性空间，称为$N^k$的**核**，记作$\ker(N^k)$。

定义$d_k$为方程组$N^k\boldsymbol{X}=\boldsymbol 0$解空间的维数：
$$
\boldsymbol{d_k=\dim\big(\ker(N^k)\big)}
$$
边界条件：$\boldsymbol{d_0=0}$。

### 零化度序列两条性质
1. 对任意$k\ge0$，有$\boldsymbol{d_k \le d_{k+1}}$。
2. 当$k$足够大，$d_k$停止增长，最终等于该特征值的**代数重数$m$**。

> $\Delta_k$描述的是：对于这个特征值，所有若尔当块里**尺寸大于等于$k$的块的总个数**，满足$\boldsymbol{\Delta_k = d_k-d_{k-1}}$。

---

## 例题
已知矩阵
$$
A=\begin{bmatrix}
-1 & 1 & 0\\
-1 & 3 & 0\\
0 & 0 & 2
\end{bmatrix}
$$

### ① 计算特征值
令 $|A-\lambda I|=0$
$$
\begin{vmatrix}
1-\lambda & 1 & 0\\
-1 & 3-\lambda & 0\\
0 & 0 & 2-\lambda
\end{vmatrix}
=(2-\lambda)\big[(1-\lambda)(3-\lambda)+1\big]
=(2-\lambda)(\lambda^2-4\lambda+4)
=(2-\lambda)^3
$$
仅有特征值 $\lambda=2$，代数重数 $m=3$。

### ② 计算 $N=A-\lambda I$
$$
N=A-2I=\begin{bmatrix}
-1 & 1 & 0\\
-1 & 1 & 0\\
0 & 0 & 0
\end{bmatrix}
$$

### ③ 求零化度序列 $d_k$
- $d_1=\dim\ker(N)$，即解 $N\boldsymbol{X}=\boldsymbol{0}$。  
设 $\boldsymbol{x}=\begin{bmatrix} x_1\\ x_2\\ x_3 \end{bmatrix}$，
$$
\begin{bmatrix}
-1 & 1 & 0\\
-1 & 1 & 0\\
0 & 0 & 0
\end{bmatrix}
\begin{bmatrix}
x_1\\ x_2\\ x_3
\end{bmatrix}
=
\begin{bmatrix}
0\\0\\0
\end{bmatrix}
\Rightarrow
\begin{cases}
x_1=x_2
\end{cases}
$$
有两个自由变量，$\boldsymbol{d_1=2}$。

- $d_2=\dim\ker(N^2)$，解 $N^2\boldsymbol{X}=\boldsymbol{0}$。  
$$
N^2=\begin{bmatrix}
0 & 0 & 0\\
0 & 0 & 0\\
0 & 0 & 0
\end{bmatrix}
$$
$N^2\boldsymbol{x}=\boldsymbol{0}$ 中 $x_1,x_2,x_3$ 全部为自由变量，$d_2=3$，已经等于代数重数 $m=3$，停止。

> 当然，敏锐的人也观察到$d_k=n-\mathrm{rank}(N^k)$，如$ d_1=3-1=2$；$d_2=3-0=3$。

得到：
$d_0=0,\ d_1=2,\ d_2=3$；且可推$d_3=3,d_4=0\cdots$

计算$\Delta_k = d_k-d_{k-1}$：
$$
\Delta_1 = d_1-d_0 = 2
$$
> $\Delta_1$：尺寸至少为1的块，一共2个。

$$
\Delta_2 = d_2-d_1 = 1
$$
> $\Delta_2$：尺寸至少为2的块，一共1个。

$$
\Delta_3 = d_3-d_2 = 0
$$
> $\Delta_3$：尺寸至少为3的块，一共0个。

根据逻辑不难推测，尺寸为2的块有1个，尺寸为1的块有1个

> 也不难发现$\Delta_{k+1}\le \Delta_k$，否则逻辑上无法说明“至少为1的块有2个但至少为2的块有114514个？”。

当然也能用块个数公式 $c_j=\Delta_j-\Delta_{j+1}$：
$$
c_1=\Delta_1-\Delta_2 = 2-1=1,\quad c_2=\Delta_2-\Delta_3=1-0=1
$$

从而可以写出该矩阵的若尔当标准型：
$$
J=\begin{bmatrix}
2 & 1 & 0\\
0 & 2 & 0\\
0 & 0 & 2
\end{bmatrix}
$$

### 关键概念回顾与应该注意的地方
1. $d_k=\dim\ker(N^k),\ N=A-\lambda I$
2. $\boldsymbol{\Delta_k = d_k-d_{k-1}}$：**大小 $\ge k$ 的若尔当块总数量**
3. $\boldsymbol{c_k=\Delta_k-\Delta_{k+1}}$：**恰好大小等于 $k$ 的若尔当块数量**
4. 性质：$\Delta_1\ge \Delta_2\ge \Delta_3\ge\cdots$，不会递增。
5. 所有块阶数加起来 $=$ 代数重数 $m$。
6. 不要把矩阵阶数n和特征值$\lambda$的重根数m搞混

---

## 心得

学习若尔当标准型时，我遇到了许多令人困惑的问题，比如若尔当矩阵存在的意义是什么？零化度序列又是什么？

而在学习这些问题的过程中我发现，我们的教材在过度追求严谨的同时，却对一些重要的推导公式进行了简化，大大增加了同学们的困惑。例如部分书中零化度序列的块公式 
$$
c_j=2d_j-d_{j-1}-d_{j+1}
$$
即使有数学直觉的同学能很快看出这显然存在一个等差序列，大多数人很难一眼得出这个式子在表达什么，只好死记硬背。

在提防此类防自学教材的同时，我们也要在听课时认真听讲，提高检索信息的能力，只有“穷究原理”方可“洞悉本质”。
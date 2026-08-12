---
title: Linux系统编程从零实战笔记（1）：从Hello World到多线程TCP服务器
description: 本系列放弃晦涩的纯理论，采用“先讲生活概念，再写代码验证，最后逐行拆解”的方式，旨在记录从零搭建环境到实现多线程高并发服务器的完整过程
date: 2026-08-11T20:51:11+08:00
image: gaoya.png
categories: [笔记]
tags:
    - Linux
    - 嵌入式
draft: true             # 发布时把 true 改成 false
---

## 第一部分：环境搭建与编译哲学

### 1. 编译器与工具链
Linux系统编程首选C语言，编译器为`gcc`。Ubuntu安装编译链：
```bash
sudo apt update && sudo apt install build-essential -y
```
**编译流程回顾：** 预处理(`.c`->`.i`) -> 编译(`.i`->`.s`汇编) -> 汇编(`.s`->`.o`目标文件) -> 链接(`.o`->可执行文件)。在Linux下可执行文件无后缀，靠`x`权限运行。

### 2. 第一个系统调用（文件IO）
**概念：** 系统编程不是改写内核，而是调用内核提供的服务（`open`, `write`, `close`）。
```c
#include <fcntl.h>
#include <unistd.h>
int main() {
    int fd = open("test.txt", O_CREAT | O_WRONLY, 0777);
    write(fd, "Hello Linux Kernel!", 19);
    close(fd);
    return 0;
}
```
**编译：** `gcc first.c -o first` && `./first`

---

## 第二部分：进程控制（Process）

### 1. 进程分叉（fork）
**概念：** `fork()` 创建子进程，父子进程共享代码段但数据隔离（写时拷贝）。
- **返回值：** 父进程返回子进程PID；子进程返回0。

### 2. 僵尸进程与 wait
**痛点：** 子进程死后若父进程不管，会变成僵尸（`<defunct>`）占着内核资源。
**解法：** 父进程必须调用 `wait()` 来“收尸”，并获取子进程退出状态码。
```c
#include <sys/wait.h>
int status;
wait(&status);
printf("子进程退出码：%d\n", WEXITSTATUS(status));
```

---

## 第三部分：多线程与竞态条件（Thread & Race Condition）

### 1. 线程的创建与共享内存
**概念：** 线程是进程内的轻量级执行流，**共享**全局变量和堆内存（不同于进程的隔离）。
```c
#include <pthread.h>
// 编译必须加 -lpthread 链接库
pthread_create(&tid, NULL, work_func, NULL);
pthread_join(tid, NULL); // 阻塞等待线程结束
```

### 2. 竞态条件的发生（单核也会出事）
**实验：** 两条线程同时对全局变量 `money` 做 10万次 `money++`。
**结果：** 结果不是 200000，因为 `money++` 在CPU层面拆为“读-改-写”三步，时间片切换导致丢失更新。
**结论：** 只要有调度器（中断/抢占），非原子操作就有竞态，与单核多核无关。

---

## 第四部分：同步原语（解决并发问题）

### 1. 互斥锁（Mutex）—— 厕所门锁
**概念：** 有所有权（谁加锁谁解锁），计数值只能是0或1，用于保护**共享资源的修改**。
```c
pthread_mutex_t mutex;
pthread_mutex_init(&mutex, NULL);
pthread_mutex_lock(&mutex);
// 临界区（共享数据操作）
pthread_mutex_unlock(&mutex);
pthread_mutex_destroy(&mutex);
```
**心法：** 只要是“改数据”，条件反射就是加互斥锁。

### 2. 信号量（Semaphore）—— 停车场显示屏
**概念：** 无所有权，计数值可以是N，用于**限流（控制并发数）** 或**同步**。
**致命误区：** 初始值为1的二值信号量**不能**替代互斥锁！因为信号量没有“所有者”机制，第三方线程可以随意 `post` 放行，破坏互斥。

### 3. 条件变量（Condition Variable）—— 门铃
**概念：** 解决“线程等待”问题，避免CPU空转（忙等待）。必须配合互斥锁使用。
**铁三角规则：**
1. `lock` 锁住共享资源。
2. `while(条件不满足) { pthread_cond_wait(&cond, &mutex); }`（内部原子性解锁+挂起，唤醒时自动加锁）。
3. 生产者满足条件后 `pthread_cond_signal` 按门铃。

**重点：** 判断条件必须用`while`不能用`if`，防止**虚假唤醒（Spurious Wakeup）**。

---

## 第五部分：网络编程基础（TCP Socket）

### 1. Socket 就是“电话”
- **服务器：** `socket`(买电话) -> `bind`(绑定号码) -> `listen`(开机) -> `accept`(接电话)。
- **客户端：** `socket`(买电话) -> `connect`(拨号)。
- **通信：** `send`/`recv`(通话) -> `close`(挂断)。

### 2. 单线程服务器的死穴
单线程 `accept` 后会卡在 `recv`，如果客户端不发数据，服务器永远无法服务下一个客户。

---

## 第六部分：终极实战——多线程TCP服务器（老板与工人模型）

### 1. 架构设计
- **老板（主线程）：** 死循环 `accept`，只负责接客。
- **工人（子线程）：** 每接一个客，创建一线程负责 `recv/send`，互不干扰。

### 2. 关键代码与踩坑笔记
**（1）保护在线人数计数器（互斥锁实战）**
```c
int online_count = 0;
pthread_mutex_t count_mutex;

// 连接建立时加锁
pthread_mutex_lock(&count_mutex);
online_count++;
pthread_mutex_unlock(&count_mutex);
```

**（2）大坑：传参必须 malloc（堆内存）**
- **错误写法：** `pthread_create(..., &client_fd)` （传栈上局部变量地址）。
- **后果：** 主循环极快，`client_fd` 被下一个连接覆盖，子线程读到错误的fd，数据错乱。
- **正确写法：**
```c
int* fd_ptr = (int*)malloc(sizeof(int));
*fd_ptr = client_fd;
pthread_create(..., handle_client, fd_ptr);
// 在线程函数里 free(fd_ptr)
```

**（3）线程分离（detach）**
```c
pthread_detach(tid); // 线程干完自动销毁，主线程无需 join，避免阻塞。
```

**（4）端口复用（解决重启报错）**
```c
int opt = 1;
setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
```

---

## 附：C语言新手常见语法疑问（FAQ）

1. **为什么线程函数是 `void* func(void* arg)`？**
   - 因为 `pthread_create` 设计为通用型，不限定参数和返回值类型，`void*` 就是“万能包裹”，由开发者自己强转。
2. **为什么全局变量要定义在函数外面？**
   - 因为定义在函数内部是“栈内存”，线程间互相不可见。必须定义在全局区或堆区才能共享。
3. **`pthread_cond_wait` 为什么传锁进去？**
   - 因为内部需要**原子性地**完成“释放锁 + 挂起线程”两个动作，防止丢失唤醒。
4. **编译时为什么总加 `-lpthread`？**
   - 因为线程库不是C标准库默认链接的，需要显式指定。

---

## 当前进度与下一步规划

- **DONE：** Linux基础IO、进程管理（fork/wait）、线程同步（互斥锁/信号量/条件变量）、TCP协议栈、多线程高并发服务器骨架。
- **TODO：** **虚拟GPIO控制**（通过读写 `/sys/class/gpio` 文件模拟物理电平）以及 **SocketCAN**（汽车总线通信），最终把网络指令转化为硬件动作。


---
title: "OS Lab: environments"
categories:
  - CS
  - labs
  - os
date: 2025-09-27 17:40:24
tags:
index: false
---
使用本地的 lldb 远程调试容器内的程序，不需要用容器内那个功能较弱的 gdb 了

```
(lldb) target create "./test"
Current executable set to '~/Source/Courses/os-lab/source/test' (riscv64).
(lldb) process connect connect://ubuntu20.orb.local:1234
Process 1 stopped
* thread #1, stop reason = signal SIGTRAP
    frame #0: 0x0000000000001000
->  0x1000: auipc  t0, 0x0
    0x1004: addi   a2, t0, 0x28
    0x1008: csrr   a0, mhartid
    0x100c: ld     a1, 0x20(t0)
(lldb)
```

将 lldb 配置写入到 codelldb 插件中，供 vscode/nvim 使用

---

远程 clangd:

容器内使用 `socat tcp-listen:2057,reuseaddr,fork exec:'clangd --background-index'` 将stdin/out 绑定到 2057 端口

nvim配置`.nvim.lua`：

```
local lspconfig = require("lspconfig")
local port = 2057

lspconfig.clangd.setup({
	cmd = {},
	root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
	on_new_config = function(new_config, _)
		-- launch command: 
		new_config.cmd = vim.lsp.rpc.connect("127.0.0.1", port)
	end,
})

```

---

riscv tool chain on mac:
https://github.com/riscv-software-src/homebrew-riscv
```
brew tap riscv-software-src/riscv
brew install riscv-tools
```

---

烧写：

安装驱动 `brew install --cask ftdi-vcp-driver`

查看新设备编号：
插入前后 diff 一下 `/dev/*`

然后把 makefile 里面的设备名字改一下

```
# DISK        = /dev/sdb
DISK        = /dev/disk6
# TTYUSB1     = /dev/ttyUSB1
TTYUSB1     = /dev/tty.usbserial-1234_tul1
```

---

编译时没有 elf.h:
下载一个，放同目录

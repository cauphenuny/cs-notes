> [!question]
> ```
> ------------------------------------------------------------
> [  2587 ns] Error!!!
>   reference: PC = 0x1c01001c, wb_rf_wnum = 0x18, wb_rf_wdata = 0xbfaff050
>   mycpu    : PC = 0x1c01001c, wb_rf_wnum = 0x18, wb_rf_wdata = 0xbfaff000
> ```

![[image-3.png]]

pre-IF 保存指令的逻辑和 IF 级接受指令的逻辑冲突了，导致这个指令既被 IF 接受，也被 pre-IF 缓存，输出到下一条指令的 `input_inst` 并拉高 `input_inst_ready`

—— 什么时候需要缓存？
—— pre-IF级接收到指令内容，**并且这个指令的取址没有被移交给 IF 级**

_de完这个又出现了一堆bug，不写了，在 pre-IF 保存指令没有前途，焯！_

重新开始

---

> [!question]
> ```
> [1585417 ns] Error!!!
>     reference: PC = 0x1c07ef00, wb_rf_wnum = 0x06, wb_rf_wdata = 0x000d02d0
>     mycpu    : PC = 0x1c07ef04, wb_rf_wnum = 0x0d, wb_rf_wdata = 0xa616d000
> ```

观察 ID 得到的指令，从 `1c07ef00` 开始错位

```asm
1c07eef8:	289f5086 	ld.w	$r6,$r4,2004(0x7d4)
1c07eefc:	289f50a4 	ld.w	$r4,$r5,2004(0x7d4)
1c07ef00:	289f50a6 	ld.w	$r6,$r5,2004(0x7d4)
1c07ef04:	5c0b4d4b 	bne	$r10,$r11,2892(0xb4c) # 1c07fa50 <inst_error>
1c07ef08:	154c2dad 	lu12i.w	$r13,-368275(0xa616d)
1c07ef0c:	0286f9ad 	addi.w	$r13,$r13,446(0x1be)
```

![[image-4.png]]

![[image-5.png]]

上一个指令还没有传给 ID 级，下一个指令的数据就从 inst_sram 返回了

两个方案：

1. 在 IF 级加一个大小为 1 的 buffer
2. 在 pre-IF 记录指令，然后传给 IF

第二种思路就是刚刚已经试过了的，不太行

改成在IF级记录一下还没处理的请求，过了


```puml
@startuml
' ================== 外观设置 ==================
skinparam backgroundColor #FFFFFF
skinparam shadowing false
skinparam ArrowColor #1e1e1e
skinparam defaultTextAlignment left

skinparam rectangle {
  BorderColor #1e1e1e
  FontName "Consolas"
}

skinparam component {
  BorderColor #1e1e1e
  FontName "Consolas"
}

title sram_axi_bridge 结构示意

' ================== 顶层模块容器 ==================
rectangle "sram_axi_bridge\n(aclk, aresetn)" as BRIDGE #FFFFFF {

  ' ====== 左侧：类SRAM 端口（Inst/Data） ======
  rectangle "Inst SRAM side" as INST_SIDE {
    () "inst_req"  as inst_req
    () "inst_wr"   as inst_wr
    () "inst_size" as inst_size
    () "inst_addr" as inst_addr
    () "inst_wstrb" as inst_wstrb
    () "inst_wdata" as inst_wdata

    () "inst_addr_ok" as inst_addr_ok
    () "inst_data_ok" as inst_data_ok
    () "inst_rdata"   as inst_rdata
  }

  rectangle "Data SRAM side" as DATA_SIDE {
    () "data_req"  as data_req
    () "data_wr"   as data_wr
    () "data_size" as data_size
    () "data_addr" as data_addr
    () "data_wstrb" as data_wstrb
    () "data_wdata" as data_wdata

    () "data_addr_ok" as data_addr_ok
    () "data_data_ok" as data_data_ok
    () "data_rdata"   as data_rdata
  }

  ' ====== 内部逻辑 ======
  package "内部控制逻辑" as CORE {

    ' --- 读请求暂存及仲裁 ---
    rectangle "读请求暂存\ninst_rd_pending/addr/size\ndata_rd_pending/addr/size\ninst_rd_ongoing\ndata_rd_ongoing" as RD_QUEUE #DDFFDD

    rectangle "读请求仲裁\n(数据读优先)\nRAW屏蔽写在途\n仅在 !wr_inflight 时接收" as RD_ARB #CCFFCC

    ' --- AR 通道 FSM ---
    rectangle "AR 通道 FSM\nar_state: IDLE/SEND\n驱动: arid/araddr/arsize/arlen\n无组合 ready/valid 依赖" as AR_FSM #CCDDFF

    ' --- R 通道 / 读缓冲 ---
    rectangle "R 通道处理\nrready 生成\n按 rid 分发\ninst_rbuf_valid/data_rbuf_valid\ninst_rdata/data_rdata\n*_data_ok 脉冲" as R_CH #CCCCFF

    ' --- 写请求暂存 ---
    rectangle "写请求暂存\nwr_pending\nwr_inflight\nwr_addr/wr_size\nwr_wdata/wr_wstrb" as WR_BUF #FFE0CC

    ' --- AW/W 通道 FSM ---
    rectangle "写地址/数据通道 FSM\nwr_state: IDLE/SEND\naw_inflight / w_inflight\n驱动: aw*, w*" as WR_FSM #FFCCAA

    ' --- B 通道 FSM ---
    rectangle "写响应通道 FSM\nb_state: IDLE/WAIT\nbready 生成\n写完成清除 wr_inflight\n产生 data_data_ok 脉冲" as B_FSM #FFDDDD

  }

  ' ====== 右侧：AXI 接口 ======
  package "AXI 总线 (Master)" as AXI {

    rectangle "AR 通道" as AXI_AR {
      () "arid"    as arid
      () "araddr"  as araddr
      () "arlen"   as arlen
      () "arsize"  as arsize
      () "arburst" as arburst
      () "arlock"  as arlock
      () "arcache" as arcache
      () "arprot"  as arprot
      () "arvalid" as arvalid

      () "arready" as arready
    }

    rectangle "R 通道" as AXI_R {
      () "rid"    as rid
      () "rdata"  as rdata
      () "rresp"  as rresp
      () "rlast"  as rlast
      () "rvalid" as rvalid

      () "rready" as rready
    }

    rectangle "AW 通道" as AXI_AW {
      () "awid"    as awid
      () "awaddr"  as awaddr
      () "awlen"   as awlen
      () "awsize"  as awsize
      () "awburst" as awburst
      () "awlock"  as awlock
      () "awcache" as awcache
      () "awprot"  as awprot
      () "awvalid" as awvalid

      () "awready" as awready
    }

    rectangle "W 通道" as AXI_W {
      () "wid"    as wid
      () "wdata"  as wdata
      () "wstrb"  as wstrb
      () "wlast"  as wlast
      () "wvalid" as wvalid

      () "wready" as wready
    }

    rectangle "B 通道" as AXI_B {
      () "bid"    as bid
      () "bresp"  as bresp
      () "bvalid" as bvalid

      () "bready" as bready
    }
  }
}


' ================== 连接关系（高层数据流） ==================

' ---- Inst/Data 请求到内部读/写逻辑 ----
inst_req  -down-> RD_QUEUE
inst_wr   -down-> RD_QUEUE
inst_size -down-> RD_QUEUE
inst_addr -down-> RD_QUEUE
inst_wstrb -down-> WR_BUF
inst_wdata -down-> WR_BUF

data_req  -down-> RD_QUEUE
data_wr   -down-> WR_BUF
data_size -down-> RD_QUEUE
data_addr -down-> RD_QUEUE
data_wstrb -down-> WR_BUF
data_wdata -down-> WR_BUF

RD_QUEUE -down-> RD_ARB

' ---- 读路径：仲裁 -> AR FSM -> AXI AR -> R 通道 -> R_CH -> inst/data 端 ----
RD_ARB -right-> AR_FSM
AR_FSM -right-> AXI_AR

AXI_R -left-> R_CH
R_CH  -left-> inst_rdata
R_CH  -left-> data_rdata
R_CH  -left-> inst_data_ok
R_CH  -left-> data_data_ok

' ---- 写路径：WR_BUF -> WR_FSM -> AXI_AW/W -> B_FSM -> AXI_B ----
WR_BUF -down-> WR_FSM
WR_FSM -right-> AXI_AW
WR_FSM -right-> AXI_W

AXI_B -left-> B_FSM
B_FSM -left-> data_data_ok

' ---- 读/写握手反馈到类SRAM 侧 ----
RD_QUEUE -left-> inst_addr_ok
RD_QUEUE -left-> data_addr_ok

' ---- R 通道 rready 由 R_CH 统一生成 ----
R_CH -right-> rready

@enduml
```

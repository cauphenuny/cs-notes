## exp13

---

因为涉及流水线阻塞逻辑，各级输出的 ex_valid 必须要在有效的情况下才拉高（不然会一直因为 older_ex 阻塞）

---

```
1c05b0fc:	1400002c 	lu12i.w	$r12,1(0x1)
1c05b100:	03bffd8c 	ori	$r12,$r12,0xfff
1c05b104:	0400102c 	csrwr	$r12,0x4
1c05b108:	0384800c 	ori	$r12,$r0,0x120
1c05b10c:	0380058c 	ori	$r12,$r12,0x1
1c05b110:	0401042c 	csrwr	$r12,0x41
1c05b114:	50000000 	b	0 # 1c05b114 <n49_ti_ex_test+0x5c>
1c05b118:	04010420 	csrwr	$r0,0x41
1c05b11c:	5c04773e 	bne	$r25,$r30,1140(0x474) # 1c05b590 <inst_error>
1c05b120:	0400000c 	csrrd	$r12,0x0
1c05b124:	03801c0d 	ori	$r13,$r0,0x7
1c05b128:	0014b58c 	and	$r12,$r12,$r13
1c05b12c:	0380100d 	ori	$r13,$r0,0x4
1c05b130:	5c0461ac 	bne	$r13,$r12,1120(0x460) # 1c05b590 <inst_error>
1c05b134:	1c00001b 	pcaddu12i	$r27,0
1c05b138:	0280b37b 	addi.w	$r27,$r27,44(0x2c)
1c05b13c:	0380100c 	ori	$r12,$r0,0x4
1c05b140:	0380100d 	ori	$r13,$r0,0x4
1c05b144:	040001ac 	csrxchg	$r12,$r13,0x0
1c05b148:	1400002c 	lu12i.w	$r12,1(0x1)
1c05b14c:	03bffd8c 	ori	$r12,$r12,0xfff
1c05b150:	0400102c 	csrwr	$r12,0x4
```


```
--------------------------------------------------------------
[1422067 ns] Error!!!
    reference: PC = 0x1c05b150, wb_rf_wnum = 0x0c, wb_rf_wdata = 0x00001bff
    mycpu    : PC = 0x1c05b150, wb_rf_wnum = 0x0c, wb_rf_wdata = 0x00001fff
```

第10位不一样，而这一位是 ECFG.LIE，对应定时器中断，所以是应该在 `1c05b114` 这里等待到定时器中断后，拉低 ECFG.LIE.IPI? 还是说只是代码里面写了关于 ECFG 的修改逻辑，检查一下。

![[image-2.png]]

![[image.png]]

也没说要把ECFG怎么搞，看代码吧

进入中断入口 `0x1c008000` 之前的状态
![[image-1.png]]

```
1c008000
```

orbstack linux machine 无法连接USB，解决方案：使用`openFPGALoader`

但 mac 环境也识别不了device，
```
empty
No cable or board specified: using direct ft2232 interface
unable to open ftdi device: -3 (device not found)
JTAG init failed with: unable to open ftdi device
```

![[Pasted image 20250923195604.png]]

系统设置中有device

使用 vid 和 pid之后，错误变了

```
openFPGALoader -b ac701 --vid 0x03FD --pid 0x0007 path-to-file.bit
empty
Cable VID overridden
Cable PID overridden
unable to open ftdi device: -6 (ftdi_usb_reset failed)
JTAG init failed with: unable to open ftdi device
```

买根线直连试试

---

试一下网络共享usb，在vivado里面打开

能共享

卡住了

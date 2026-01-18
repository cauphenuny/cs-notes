- 测试local block较多时，大一些的模型的MAN效果以及扰动效果。
	结果：
	- MAN效果很好
	- 但在加扰动的结果几乎与baseline齐平
		![[Pasted image 20250911201927.png]]
		![[Pasted image 20250911202249.png]]
	- 下一步测试一下在不带MAN的arch中扰动的效果
	- 也可以调整扰动的比例（比如只在20%, 10%,5%的时间内扰动）
		结果：![[Pasted image 20250915163308.png]]
		只在25%时间内扰动的结果与baseline还是几乎一样

	- 在imagenet和cifar数据集上的辅助网络实现有一些区别，试一试效果不好会不会是辅助网络的问题（但MAN的效果确实很好

- 测试HunyuanGameCraft
	- 输出的是竖条纹乱码，正在排查原因
	- 试了一下，在A800上能正常输出，在昇腾上我只改动了flash attn部分，将torch_npu.npu_fusion_attention adapt到了flash attn的接口，会不会是这里问题？
	- 对比计算全流程，发现在vae encode阶段就不相同了，然后逐个对比tensor，从conv层开始有一些误差，然后 `nn.functional.pad` 之后误差突然变大
	  ![[Pasted image 20250915164539.png]]
	- 复现出pad的最小错误例子，然后反馈一下

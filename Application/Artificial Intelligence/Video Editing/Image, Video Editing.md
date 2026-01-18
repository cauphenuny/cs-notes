---
title: 
tags:
  - Algorithm
  - CV
---
---
## ICE

In-context editing:

- Text to Image: 图像反演，注入注意力值
- Inpainting: 并排放置，左侧是原图像，右侧被遮挡

Early filter:
- 用VLM选出合适的初始种子

Structure:
主干网络：FLUX.1 fill
在注意力层输出加上了MoE, LoRA，微调

Dataset:
MagicBrush + OmniEdit

## Step1X-Edit

数据组成：
- 添加/删除对象：用Florence-2标注，然后SAM-2分割，使用ObjectRemovalAlpha修复，然后用step-1o/GPT-4o生成编辑指令
- 主题/背景更换：跟添加/删除对象类似
- 颜色/材料更改：用Zeodepth进行深度估计，然后分析出形状，用ControlNet生成新图像
- 运动变化
- 人像编辑
- 风格迁移
- 色调变化

模型：

MLLM(frozen), 输出 token embedding

实现跨模态：
- FLUX-Fill：channel concat
- SeedEdit: casual self-attention
- *OminiControl, this: token concat*

## ACE

统一多种任务输入，使用条件单元 CU：$\text{CU}=\{ T,V \},V=\{ [I^1;M^1],[] \}$


![[ACE.png]]
![[ACE structure.png]]
## ACE++

- LCU++：改进LCU，改成通道连接, $V^{++}=\{ I^{in},M^{in},X_{t}\}$, $I$: image, $M$: mask, $X$: noise_t
![[ACE++.png|206x300]]

- 使用FLUX.1-dev作为主干
- 两阶段训练，先训 0-ref 的，然后N-ref

## Smart Edit

## InstructPix2Pix



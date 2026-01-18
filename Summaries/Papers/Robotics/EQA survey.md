## 顶会

> [!info] OpenEQA
> OpenEQA: Embodied Question Answering in the Era of Foundation Models 
> **CVPR2024**
^57e796

主要提出了 OpenEQA 数据集，测试了几种 VLM

跟其他的benchmark的比较

![[openEQA.png]]

提出 _EM-EQA_ (episodic memory) 和 _A-EQA_ (active exploration)，

在以下类型的模型上测试了：
- Blind LLM
- Socratic LLMs: 通过几帧生成caption，然后送到LLM里回答问题
- VLM
- Human Agent

![[openEQA_result.png|450x390]]

---

> [!info] 3D-Mem
> 3D-Mem: 3D Scene Memory for Embodied Exploration and Reasoning
> **CVPR2025**
> > Code: https://github.com/UMass-Embodied-AGI/3D-Mem
> > 内容较全，支持直接 run evaluation on _A-EQA_, _GOAT-Bench_

Benchmarks:
- _A-EQA_ (from [[#^57e796|OpenEQA]])
	- LLM-Match: 52.6 (subset)
	- LLM-Match SPL: 42.0 (subset)
	![[3dmem_A-EQA.png|446x274]]
	SPL: 按路径长度加权

- _EM-EQA_ 
	57.2
	![[3dmem_EM-EQA.png|357x405]]

- _GOAT-Bench_
	GOAT-Bench: 导航benchmark
	Result(subset): Success Rate 69.1, SPL 48.9
	![[3dmem-GOATBench.png|467x387]]

在整个数据集上的评估结果：
![[3dmem-FullBenchmark.png|393x248]]

---

> [!info] PhysVLM
> PhysVLM: Enabling Visual Language Models to Understand Robotic Physical Reachability
> **CVPR2025**
> > code: https://github.com/jetteezhou/PhysVLM
> > 较完整，有code, simulator

造了个benchmark _EQA-phys_，重点在于 physical reachability?

![[physVLM_EQA-phys.png]]

ref:
Spatial VLM, CVPR2024
SpatialBot, arXiv:2406.13642
3D-VLA, arXiv:2403.09631

---

> [!info] SpatialVLM
> SpatialVLM: Endowing Vision-Language Models with Spatial Reasoning Capabilities
> **CVPR2024**
> > code: https://spatial-vlm.github.io/#community-implementation
> > 只有dataset pipeline，还是第三方实现的

好像是VQA的，没说EQA

Benchmark: _Spacial EQA_

---

> [!info] ECBench
> ECBench: Can Multi-modal Foundation Models Understand the Egocentric World? A Holistic Embodied Cognition Benchmark
> **CVPR2025**
> > code: https://github.com/Rh-Dang/ECBench

又是一个benchmark，卖点似乎是 Robot Centric 以及 Hallucination
![[ECBench_compare.png]]

测试：
![[ECBench_result.png]]

---

> [!info] IndustryEQA
> IndustryEQA: Pushing the Frontiers of Embodied Question Answering in Industrial Scenarios
> **NIPS2025**

造了工业场景下的 EQA benchmark

使用 Issac Sim 构造模拟数据

跟其他的benchmark的对比：
![[industryEQA_compare.png|619x216]]


测试的baseline models：
与OpenEQA类似，blind LLM, Multi-Frame VLLMs 和 Video VLLMs

![[industryEQA_baselines.png|499x280]]

---

> [!info] Mars
> Mars: Situated Inductive Reasoning in an Open-World Environment
> **NIPS2024**

benchmark: 情景归纳推理：创建了一个环境 _Mars_，基于 Crafter，每个世界可以有新的规则，测试agent归纳推理的能力。
![[mars_compare.png|633x235]]

---

> [!info] OmniJARVIS
> OmniJARVIS: Unified Vision-Language-Action Tokenization Enables Open-World Instruction Following Agents
> **NIPS2024**

一种VLA模型，在minecraft上进行评估 (benchmark: _mc-eqa-300k_ )

![[OmniJARVIS.png|536x256]]


---

> [!info] EQA-MX
> EQA-MX: Embodied Question Answering using Multimodal Expression
> **ICLR2024 Spotlight**

造了一个数据集，卖点：在VQA的基础上加入了非语言手势、多语言、多视角、具身交互（导航）
![[EQA-MX.png]]


---

## 其他

- Explore until Confident: Efficient Exploration for  Embodied Question Answering

**RSS 2024**

自建数据集 _HM-EQA_，基于Habitat-Matterport 3D Research Dataset (HM3D) 构建，包含多样化、真实的人机交互场景和室内3D扫描

在 Fetch 机器人上做了真实实验

![[explore-until-confident.png]]

---

- Map-based Modular Approach for Zero-shot Embodied Question  Answering

**IROS 2024**

exp on _MP3D-EQA_ dataset, VQA top-1 accuracy: around 0.43

![[Map-based-MAZ-EQA.png]]

---

- Scene-LLM

Claims SOTA on _ScanQA, SQA3D_ benchmarks.
When fine-tuned for specific tasks, Scene-LLM outperforms other LLM-based models on the Alfred benchmark

![[ScanQA result.png]]


![[SQA3D result.png]]

![[Alfred result.png]](Alfred: 衡量计划high level goal, plan 的能力)

---

## 总结

似乎做 benchmark 的比较多，只有很少的 paper 不造数据集或 benchmark，比如 3D-Mem, OmniJARVIS。
做 benchmark 的这些 paper 一般拿 VLM 当 baseline 测试。
benchmark太多了，目前不知道是否有公认的标准，填坑的论文看起来比较少。
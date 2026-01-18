chat-scene:
![[chat-scene.png]]

3D Graph LLM:
![[3d-GraphLLM.png]]

Descrip3D:
![[descrip3d.png]]
对于 3DGraphLLM 的描述与 3DGraphLLM 本身不一致？

GPT4Scene:
![[GPT4Scene.png]]

![[ross3d.png]]

3DGraphLLM论文中有 SQA3D benchmark 的 Method:
- GPT4Scene (EM 60.6, EM-R 63.3): https://github.com/Qi-Zhangyang/GPT4Scene-and-VLN-R1
- Robin3D (EM 56.0): Coming soon.
- 3DGraphLLM (EM 55.9): https://github.com/cognitiveaisystems/3dgraphllm released model "pre-training on GT instance segmentation scene graphs"
- ChatScene (EM 54.6, EM-R 57.5): https://github.com/ZzZZCHS/Chat-Scene checkpoint available on Google Drive
- SceneLLM (EM 54.2): 没开源

引用了 3DGraphLLM 且在 SQA 上测试的论文：
- Fast3D: Accelerating 3D Multi-modal Large Language Models for Efficient 3D Scene Understanding
	做的token剪枝
- **Descrip3D**: Enhancing Large Language Model-based 3D Scene Understanding with Object-Level Text Descriptions
	(SQA3D EM55.7 EM-R 58.4)
	没开源

引用了 GPT4Scene 且在 SQA 上测试了的论文：
- 3D-R1: Enhancing Reasoning in 3D VLMs for Unified Scene Understanding 没给benchmark平均值
- **VeBrain**: arXiv:2506.00123 (**SQA3D EM61.6 EM-R 64.9**) <https://github.com/OpenGVLab/VeBrain?tab=readme-ov-file> (coming soon).
- **Ross3D** (_ICCV2025_): arXiv:2504.01901 (**SQA3D EM 63.0 EM-R 65.7**) <https://github.com/haochen-wang409/ross3d>
- Spatial-MLLM: Boosting MLLM Capabilities in Visual-based Spatial Intelligence (SQA3D 55.9/58.7)
- **3DRS**: MLLMs Need 3D-Aware Representation Supervision for Scene Understanding (SQA3D 60.6) <https://github.com/Visual-AI/3DRS> no checkpoints
- Struct2D: A Perception-Guided Framework for Spatial Reasoning in Large Multimodal Models (SQA3D 58.5/61.3) <https://github.com/neu-vi/struct2d> no evaluation
- LEO-VL: Efficient Scene Representation for Scalable 3D Vision-Language Learning (SQA 60.8/63.7) 没开源
- Text-Scene: A Scene-to-Language Parsing Framework for 3D Scene Understanding (SQA3D 61.2) 没开源

| 论文短名              | SQA3D EM / EM-R | 代码地址                                                            | 备注                                                                     |
| ----------------- | --------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Ross3D            | 63.0 / 65.7     | [GitHub](https://github.com/haochen-wang409/ross3d)               | 已开源                                                                    |
| VeBrain           | 61.6 / 64.9     | [GitHub](https://github.com/OpenGVLab/VeBrain?tab=readme-ov-file) | 开源，但coming soon                                                            |
| Text-Scene        | 61.2 / –        | –                                                                 | 未开源                                                                    |
| LEO-VL            | 60.8 / 63.7     | –                                                                 | 未开源                                                                    |
| GPT4Scene         | 60.6 / 63.3     | [GitHub](https://github.com/Qi-Zhangyang/GPT4Scene-and-VLN-R1)    | 已开源                                                                  |
| 3DRS              | 60.6 / –        | [GitHub](https://github.com/Visual-AI/3DRS)                       | 无 checkpoint                                                           |
| Struct2D          | 58.5 / 61.3     | [GitHub](https://github.com/neu-vi/struct2d)                      | 无 evaluation script                                                    |
| Robin3D           | 56.0 / –        | [Github](https://github.com/WeitaiKang/Robin3D)                   | 开源，但coming soon                                                                  |
| 3DGraphLLM        | 55.9 / –        | [GitHub](https://github.com/cognitiveaisystems/3dgraphllm)        | released model “pre-training on GT instance segmentation scene graphs” |
| ChatScene         | 54.6 / 57.5     | [GitHub](https://github.com/ZzZZCHS/Chat-Scene)                   | 已开源                                  |
| SceneLLM          | 54.2 / –        | –                                                                 | 未开源                                                                    |
| Descrip3D         | 55.7 / 58.4     | –                                                                 | 未开源                                                                    |
| Spatial-MLLM      | 55.9 / 58.7     | –                                                                 |                                                                        |
| Fast3D            | – / –           | –                                                                 | 做的是 token 剪枝，result 比 baseline 差                                                        |
| 3D-R1             | – / –           | –                                                                 | 没给 result 平均值                                                       |


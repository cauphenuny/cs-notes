## Review: What Matters in Building VLAs

Four questions: 

- Why do we prefer VLA
	VLAs outperform than other approachs by a large margin.
- Which kind of VLM backbones is more suitable for robot.
	KosMos and Paligemma
- How should we formulate VLAs?
	Continuous actions space + history data + policy head.
- When should we add cross-embodiment datasets?
	Pre-train by cross-embodiment data, then fine tune with in-domain data.

Notes:

only decoder-only architecture can use interleaved history fusion.

Limitations:

- Is there any specialized architecture that can gain superior performance?
- Categorizations and formulations are simplified
- Other action tokenization, policy head, and corresponding training objectives.
- Real-time robotic control

## RoboBrain: A Unified Brain Model for Robotic Manipulation  from Abstract to Concrete

### Introduction

Recent studies have limits on long-horizon manipulation tasks.
ShareRobot: a large-scale, fine-grained dataset for robotic operation tasks.
RoboBrain: state-of-art mllm for robotic manipulation
### Features of ShareRobot

- Fine-grained: detailed instructions, unlike general inst. in Open X-Embodiment dataset.
- Multi-dimensional: task-planning, object affordance, end-effector trajectories.
- High-quality: high resolution, visible affordance, clear trajectories, successful tasks.
- Large-scale
- Rich-diversity
- Easy-scalability

### Data Labeling of ShareRobot

- Plan: Use 30 frames from each operation, added with general instruction, decompose to lower instruction using Gemini, with annotators reviewing and revising. The low level inst. are aligned with RoboVQA structure.
- Affordance/Trajectory: annotate bounding boxes, train a gripper detector

### The RoboBrain Model

Three parts:
- Foundational Model for planning: Vision Encoder  $g$ + Projector $h$ + LLM $f$
- A-[[LoRA]]/T-LoRA for affordance/trajectory perception.

Training phases:
- General OneVision Training: Projector $\to$ image-text data, learn multi-modal knowledge $\to$  image video data, instruction following ability
- Robotic Training: predict trajectories, get manipulation skills $\to$ robotic manipulation planning $\to$ object affordance perception

Evaluate metrics:
- Planning: [[BLEU]] 1-4
- Trajectory: [[Discrete Frechet Distance]] + [[Hausdorff Distance]] + Root Mean Square Error
- Affordance: average precision

RoboBrain significantly outperforms existing multimodal large language models (MLLMs) in robotic benchmarks, excelling in task planning, trajectory prediction, and affordance perception. It achieved a BLEU-4 score of 55.05 in RoboVQA and outperformed GPT-4V in OpenEQA. In trajectory prediction, RoboBrain showed high accuracy across various metrics, while its average precision (AP) for affordance prediction reached 27.1%, surpassing competitors. In experiments, incorporating the ShareRobot dataset enhanced performance, with a 4:6 ratio of robotic to general data yielding optimal results. However, some errors in object recognition and planning indicate areas for improvement. Overall, RoboBrain demonstrates substantial potential to advance robotic manipulation capabilities.

## RoboTwin

### Framework Introduction: 

RoboTwin uses 3D generative models and LLMs to generate diverse training data and benchmarks for dual-arm robotic tasks, addressing data scarcity and simulation-real-world gaps.  
### Key Contributions:  
  1. Real-to-Sim Pipeline: Generates 3D object models from single 2D images using generative foundation models.  
  2. Spatial-Aware Code Generation: Combines LLMs with object annotations to decompose tasks, infer constraints, and generate executable robot code.  
  3. Standardized Benchmark: Includes 15 dual-arm tasks with real-world and synthetic data for consistent evaluation.  
### Methodology:  
  - Creates digital twins with spatial annotations (functional/contact points, axes) for task-specific reasoning.  
  - LLMs decompose tasks into subtasks, optimize trajectories, and handle collision avoidance. 
### Experiments:  
  - Pre-training on 300 synthetic samples + fine-tuning on 20 real samples improves success rates by 70% (single-arm) and 40% (dual-arm) vs. real-data-only training.  
  - 3D input policies outperform 2D in complex tasks due to better spatial reasoning.  
### Benchmark Details:  
  - Tasks include hammering, handovers, stacking, and coordinated placements.  
  - Uses the COBOT Magic Robot platform with synchronized arms and RGBD cameras.  
###  Limitations: 
Challenges remain in high-precision dual-arm coordination and handling thin objects in point-cloud data.  
###  Future Work:
Enhancing algorithms for dual-arm collaboration and expanding task diversity.

## RoboBert

Focus on efficient robot training on small datasets.

Related Works:
- end-to-end robotic model
- imitation learning
- multimodal fusion: by projection, by queue, fine-tuning

Structure:
Feature Extractor $M_{ext-\theta}$
Modality Fusion $M_{fusion-\theta}$
Action Head $M_{policy-\theta}$

Tricks:
Two-stage training: standard language, frozen ViT $\to$ unfreeze ViT, fine-tune; natural language
Data Augmentation:
- Salt-Pepper Noise $+0.22$: add white/black pixels
- Affine Transformation $-0.25$
- Color Jitter $+0.65$: adjust color in HSV space, the mentioned color would remain.
- Robotic Mixup $+0.23$: weighted average two different samples
- All combined: $+0.52$
- without affine: $+0.79$

Results:
- RoboBERT achieves an average length of 4.52 on the CALVIN benchmark for the ABCD→D task, setting a new state-of-the-art (SOTA) record.  
- When tested on a real robot, RoboBERT demonstrates superior performance, achieving a higher success rate than other methods trained with the same data.

## Chain-of-Affordance

- Object affordance: Object affordance enables the robot to determine what object to interact with and where it is located, particularly when a user query lacks explicit instructions.
- Grasp affordance: Grasp affordance encompasses the possible functions or ways an object can be manipulated.
- Spatial affordance: Spatial affordance is about spatial relations as an indicator of a model’s ability to understand a 3D world.
- Movement affordance: Movement affordance defines the trajectory a robot can follow during a task.

Representing Affordance: by text / image

Generating Affordance: use GPT-4o to generate descriptions of specific scene and recognize entities from instruction. then use Grounding DINOv2 and SAM to generate bounding boxes.

Evaluation:
- Spatial Affordance for CoA. CoA can identify free space for object placement.
- Movement Generalization for CoA. CoA can avoid obstacles and operate safely.
- Generalization on Object Pose. CoA can pick up objects with unseen poses, benefiting from grasp affordance.
- In addition, CoA have the capability to avoid obstacles, generalize to unseen object poses

## DexVLA

Existing challenges: data scarcity; architectural imbalance: prioritize scale up vlm module.

### Two Key innovations:
- Diffusion Expert: multihead for different embodiment, scaled to 1B.
- Three-Stage curriculum embodiment learning: Cross embodiment pre-training $\to$ embodiment specific alignment $\to$ task specific adaptation

### Architecture:
- the structure of diffusion expert: [[ScaleDP]], Scale Diffusion Policy
- ViT converts visual inputs to embedding same as language tokens.
- train loss: $L=L_{diff} + \alpha L_{ntp}$, after pre training, the magnitude of two loss are similiar, so $\alpha$ is set to $1$

### Details of Three Stage learning:
- Cross embodiment pre-training:
	- sub-task annotations, using a [[FiLM ]] layer to inject language prompts to policy model.
	- a multi-head output

- Embodiment:
	- filter data, ensure that one sample only regarding specific embodiment.
	- [[Mirroring techniques]]
	- frozen visual encoder of VLM.

- Task specific:
	- require model to learn and generate sub-task instructions, using the reasoning capability from VLM backbone, instead of high-level policy models like SayCan from [[VLA Papers#$pi_0$]]

### Results:
- The model is pre-trained on only 100 hours of demonstration data and runs at 60Hz on a single Nvidia A6000 GPU, enabling cost-efficient training and fast inference.
## $\pi_0$

A Vision-Language-Action Flow Model for General Robot Control

Introduce: developing general robotic policy may face challenges: demand on large dataset, appropriate model architecture, and most important, right training recipe.

Then the $\pi_{0}$ framework of prototype model and training is presented.

Architecture:
- Action Chunking
- [[Flow Matching]], a variant of diffusion to represent complex continuous action distributions, modeling $p(\mathbf{A}_{t}|\mathbf{o}_{t}), \text{where} \mathbf{A}_{t}=[\mathbf{a}_{t}, \mathbf{a}_{t+1}, \dots \mathbf{a}_{t+H-1}]$ is the actions, and $\mathbf{o}_{t}$ is the observation comprises multiple RGB images, language instruction, and robot's state. $\mathbf{a}_{i}$ have the most degree of free among all robots.
- Novel _action expert_ that augments the standard VLM with flow-based outputs.

Compared to related works:
- Former VLA models ultilize autoregressive discretization to represent actions in a manner analogous to text tokens. In contrast, our model employs a novel design that fine-tunes a VLM to produce actions via flow matching $\to$ first flow matching VLA that produces high-frequency action chunks.
- Larger dataset: about $10000$ hours, aux. with Open X-Embodiment dataset.

Training:
- use both high-quality data and lower-quality data. because errors roughly emerges in high quality datasets, and only rely on lower quality data would not teach model to act robustly and effectively.
- weight each task by $n^{0.43}$ for balancing dataset size in different tasks

Result:
![[Pasted image 20250421213219.png]]

for language aspect, $\pi_0$ performs better than $\pi_0-small$, and instructed by human or high-level VLM can gain substantial improve.

![[Pasted image 20250426144613.png]]
π0 can learn some easier tasks even with smaller amounts of data, and the pre-trained model often attains a larger improvement over the model trained from scratch.
## Diffusion VLA

Combined next-token-predict and diffusion models.

1. Architecture:  
   - Combines a pre-trained vision-language model (VLM) for processing inputs with a latent diffusion model for action generation.  
   - Introduces a reasoning injection module using Feature-wise Linear Modulation (FiLM) to embed reasoning signals into policy learning, enhancing interpretability and adaptability.  

2. Key Features:  
   - Fast Inference: Achieves 82Hz on a single A6000 GPU (2B model), enabling real-time deployment.  
   - Robust Generalization: Demonstrates resilience to visual distractions, novel backgrounds, and unseen objects (e.g., 63.7% success in zero-shot bin picking with 102 unseen items).  
   - Scalability: Scales from 2B to 72B parameters, showing improved performance with model size (e.g., 82.4% success in factory sorting with the 72B model).  
   - Adaptability: Successfully transfers to bimanual robots and novel instructions while retaining conversational abilities.  

3. Experiments:  
   - DiVLA can categorize objects, including those not seen during training.
   - Outperforms baselines (Diffusion Policy, TinyVLA, OpenVLA) in multi-task learning, factory sorting, and real-world bimanual tasks.  
   - Maintains high success rates under visual variations (distractors, lighting changes) and view shifts, showcasing robustness.  

4. Limitations:  
   - Performance degrades with low-bit quantization, requiring specialized methods for efficient deployment.  
   - Relies on pretrained VLMs, limiting flexibility in model choice.  

DiVLA advances robotic control by unifying reasoning and action generation, offering a scalable and efficient solution for complex real-world tasks.

## OmniManip

### Key Challenges
- VLM Limitations: Existing Vision-Language Models (VLMs) excel at high-level reasoning but lack fine-grained 3D spatial understanding, limiting their utility in low-level robotic control.
- Data and Generalization Bottlenecks: Fine-tuning VLMs into Vision-Language-Action Models (VLAs) faces high data collection costs and poor generalization across tasks and robots.

### Core Methodology
1. Object-Centric Interaction Primitives  
   - Canonical Space: Defines interaction primitives (points and directions) within an object’s functional affordance-aligned coordinate system. For example, a teapot’s handle (interaction point) and pouring axis (direction) remain consistent across scenarios.  
   - Spatial Constraints: Tasks are decomposed into stages, each governed by geometric constraints (distance and angular alignment) between active and passive objects.
2. Dual Closed-Loop System  
   - Planning Loop: Employs *Resampling, Rendering, and Checking (RRC)* to iteratively refine interaction primitives using VLM feedback. RRC renders candidate interactions, validates them via VLM, and resamples if misaligned, mitigating hallucinations.  
   - Execution Loop: Optimizes end-effector trajectories using constrained loss functions (spatial alignment, collision avoidance, path smoothness) and real-time 6D pose tracking for robustness.
3. Task Decomposition and Optimization  
   - Complex tasks (e.g., *pour tea*) are split into stages (grasp, pour). Each stage’s spatial constraints guide trajectory optimization via loss minimization:  
     $$
     \mathbf{P}^{ee} = \arg\min \left\{ \mathcal{L}_C + \mathcal{L}_{\text{collision}} + \mathcal{L}_{\text{path}} \right\}
     $$
   - $\mathcal{L}_C$ ensures alignment with primitives, $\mathcal{L}_{\text{collision}}$ prevents collisions, and $\mathcal{L}_{\text{path}}$ enforces smooth motion. (Online optimization)

### Experimental Results
- Zero-Shot Generalization: Achieved 68.3% success on rigid-object tasks (vs. 15-45% for baselines) and 61.7% on articulated tasks (vs. 16.7-26.7%), demonstrating strong generalization across 12 open-vocabulary tasks.
- Key Advantages:
  - Viewpoint Invariance: Success rates vary by <10% across viewpoints (vs. >70% for surface-based methods like ReKep).  
  - Closed-Loop Impact: Dual loops improve planning success by >15% and handle dynamic execution errors.

### Applications and Limitations
- Applications: Enables zero-shot automated demonstration generation for imitation learning (behavior cloning success rates >85%).  
- Limitations: Cannot model deformable objects, depends on 3D mesh quality, and incurs computational overhead from frequent VLM calls.

### Innovations
- First Dual Closed-Loop System: Combines closed-loop planning (RRC) and execution (pose tracking) without VLM fine-tuning.  
- Canonical Interaction Primitives: Bridges high-level VLM reasoning with low-level control via functional-geometric alignment.  
- Scalable Framework: Provides a foundation for open-vocabulary manipulation in unstructured environments.  

This work addresses critical gaps in robotic manipulation by integrating semantic reasoning with precise spatial constraints, paving the way for more adaptable and data-efficient robotic systems

## ASAP

Existing methods like system identification (SysID) and domain randomization (DR) face challenges such as labor-intensive tuning or overly conservative policies. ASAP addresses these through a two-stage process:

1. **Pre-training**: Policies are trained in simulation using human motion videos retargeted to robots, with techniques like phase-conditioned tracking and domain randomization to enhance robustness.
    
2. **Post-training**: Real-world data is used to train a delta action model that compensates for sim-to-real discrepancies. This model adjusts actions in simulation, enabling policy fine-tuning aligned with real-world dynamics.

Experiments across sim-to-sim (IsaacGym to IsaacSim/Genesis) and sim-to-real (Unitree G1 robot) transfers demonstrate ASAP’s effectiveness. It reduces motion tracking errors by up to 52.7% compared to baselines. Key contributions include the delta action model for dynamics alignment, successful deployment of agile whole-body policies, and an open-source multi-simulator training framework. Limitations include hardware stress during data collection and reliance on motion capture systems. The work advances sim-to-real transfer for dynamic humanoid tasks.
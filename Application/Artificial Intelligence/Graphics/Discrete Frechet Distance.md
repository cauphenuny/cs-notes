---
tags:
  - Algorithm
  - Graphics
---
---

### **核心定义**
假设有两条多边形曲线：
- 曲线 $P = \{ p_1, p_2, \dots, p_n \}$
- 曲线 $Q = \{ q_1, q_2, \dots, q_m \}$

离散弗雷歇距离通过**耦合（coupling）** 两曲线的顶点序列，计算所有可能耦合中**最大步长**的最小值。形式化定义为：
$$
\delta_{\text{DFD}}(P, Q) = \min_{C} \left( \max_{(i,j) \in C} d(p_i, q_j) \right)
$$
其中：
- $C$ 是从 $P$ 到 $Q$ 的合法耦合序列（需覆盖所有顶点，且顺序不可逆）。
- $d(p_i, q_j)$ 是点 $p_i$ 和 $q_j$ 之间的欧氏距离。

---

### **直观解释**
想象两个人分别沿曲线 $P$ 和 $Q$ 行走，每一步必须移动到下一个顶点（不可停留或回退）。离散弗雷歇距离是两人同步移动时，**所需绳子的最短最大长度**。  

---

### **与连续弗雷歇距离的区别**
| 特性        | 离散弗雷歇距离       | 连续弗雷歇距离        |
| --------- | ------------- | -------------- |
| **定义域**   | 仅考虑曲线顶点       | 考虑曲线上所有连续点     |
| **计算复杂度** | $O(nm)$（动态规划） | 计算困难，需几何算法近似   |
| **应用场景**  | 轨迹分析、多边形匹配    | 理论分析、连续曲线相似性评估 |

---

### **计算步骤（动态规划）**
1. 构建距离矩阵 $D \in \mathbb{R}^{n \times m}$，其中 $D[i][j] = d(p_i, q_j)$。
2. 初始化动态规划表 $\text{DP}[i][j]$，表示从 $(1,1)$ 到 $(i,j)$ 的最小最大距离。
3. 递推公式：
$$
   \text{DP}[i][j] = \max \left( D[i][j], \min \left( \text{DP}[i-1][j], \text{DP}[i][j-1], \text{DP}[i-1][j-1] \right) \right)
$$
4. 最终结果 $\delta_{\text{DFD}} = \text{DP}[n][m]$。

---

### **典型应用**
1. **轨迹相似性分析**  
   比较机器人运动轨迹、动物迁徙路径的相似性。
2. **形状匹配**  
   在计算机视觉中匹配多边形轮廓（如手写字符识别）。
3. **时间序列对齐**  
   对齐传感器数据（如心电图信号、股票价格序列）。
4. **地理信息系统（GIS）**  
   评估道路网络、河流路径的拓扑差异。

---

### **优缺点**
- **优点**：  
  - 计算高效，适合处理离散点序列。  
  - 保留对曲线顺序的敏感性（优于Hausdorff距离）。  
- **缺点**：  
  - 对顶点密度敏感（稀疏采样可能导致误差）。  
  - 忽略曲线形状的局部细节（如曲率变化）。

---

### **代码实现示例（Python）**
```python
import numpy as np

def discrete_frechet_distance(P, Q):
    n, m = len(P), len(Q)
    D = np.zeros((n, m))
    for i in range(n):
        for j in range(m):
            D[i][j] = np.linalg.norm(P[i] - Q[j])
    
    DP = np.zeros((n, m))
    DP[0][0] = D[0][0]
    for i in range(1, n):
        DP[i][0] = max(DP[i-1][0], D[i][0])
    for j in range(1, m):
        DP[0][j] = max(DP[0][j-1], D[0][j])
    
    for i in range(1, n):
        for j in range(1, m):
            DP[i][j] = max(D[i][j], min(DP[i-1][j], DP[i][j-1], DP[i-1][j-1]))
    
    return DP[-1][-1]
```

---

### **扩展阅读**
- **经典论文**：  
  [Eiter, T., & Mannila, H. (1994). Computing Discrete Fréchet Distance. *Technical Report CD-TR 94/64*](https://www.kr.tuwien.ac.at/staff/eiter/et-archive/cdtr9464.pdf)  
- **优化方法**：  
  [Bringmann, K., & Mulzer, W. (2016). Approximability of the Discrete Fréchet Distance. *Journal of Computational Geometry*](https://jocg.org/index.php/jocg/article/view/303)  

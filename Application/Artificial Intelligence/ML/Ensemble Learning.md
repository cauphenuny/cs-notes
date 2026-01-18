Bootstrap Sampling

对数据集 $\mathcal{D}$ 重采样：
有放回抽取

原始数据中每个数据有 $\left( 1-\dfrac{1}{N} \right)^{N}$ 概率不被选中 ($N=\lvert \mathcal{D} \rvert$)

不重复样本数量期望：$N\left( 1-\left( 1-\dfrac{1}{N} \right)^{N} \right)\approx {0}.632N$

---

Bagging:
用 bootstrap 采样之后的几组数据分别训练模型，然后平均

---

随机森林：
特征也sample，从总共的特征 ($d$维) 中选几项 ($\sqrt{ d }$ 维)
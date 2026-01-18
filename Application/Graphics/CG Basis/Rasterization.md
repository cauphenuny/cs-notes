通过在像素中心采样决定这个像素是否被颜色覆盖

$\implies$ 问题：走样（aliasing)

判断点是否在三角形内：

求三个向量叉积，判断正负，如果全正/全负则在三角形内部

ref:
https://scarletsky.github.io/2020/06/10/games101-notes-rasterization/

Anti-aliasing: 根据图像在像素中的占比来绘制颜色

很难计算面积，可以用超采样 (MSAA) 模拟面积计算
![[supersample0.png]]![[supersample1.png]]


**判断点是否在多边形内部**：

作一条射线，判断与边界相交的次数，偶数则在外部，奇数则在内部



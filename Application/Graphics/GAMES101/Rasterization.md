
> [!theorem] Convolution Theorem
> 卷积等于在频域上按元素乘卷积核的频域

![[conv.png]]

Z-buffer

离视点越近，Z值越大，init: Z=-inf, 绘制图形时更新，若 `cmin(zbuffer(x,y), z(x,y))` 有更新，则更新颜色为当前图形颜色

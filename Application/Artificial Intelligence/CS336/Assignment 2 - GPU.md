## GPU components:
SM $\implies$ SP
SM: Streaming Multi-processor
SP: Streaming Processor

Block $\to$ (Threads $\Leftarrow$Warps)
Warps: batch of threads
Block: multi threads, assigned to specific SM.

---

## Instruction Model:

SIMT: single instruction, multi threads, every threads in a **warp** execute same instruction, while different data.

---

## Improve GPU performance:
1. Control divergence
2. Low precision computation
3. Operator fusion
4. Recomputation
5. Coalescing memory
6. Tiling

### Control Divergence

Since all threads must exec same instruction, so whenever there comes a conditional statement, some threads would stop for non-true condition, where rest executing.

![[Pasted image 20250920185625.png]]

### Operation Fusion
Multi operations per memory transfer.

---

> [!question] Benchmarking
> Benchmark the forward and backward pass for the model size below:
> ![[Pasted image 20250921222920.png]]
> How long does a forward pass take? How about a backward pass? Do you see high variability across measurements, or is the standard deviation small?
> One caveat of benchmarking is not performing the warm-up steps. Repeat your analysis without the warm-up steps. How does this affect your results? Why do you think this happens? Also try to run the script with 1 or 2 warm-up steps. Why might the result still be different?

context length: 256, 5 warmup, 10 step:

|     | model                      |      mean |         std |
| --: | :------------------------- | --------: | ----------: |
|   0 | small (forward, backward)  | 0.0629162 |  0.00147046 |
|   1 | small (forward only)       | 0.0205024 | 1.40257e-05 |
|   2 | medium (forward, backward) |  0.191128 |  0.00114081 |
|   3 | medium (forward only)      | 0.0616703 | 9.35236e-05 |
|   4 | large (forward, backward)  |  0.418967 | 0.000605803 |
|   5 | large (forward only)       |   0.13738 |  0.00134835 |
|   6 | xl (forward, backward)     |  0.866344 |  0.00247804 |
|   7 | xl (forward only)          |  0.282835 |  0.00296444 |
|   8 | 2.7B (forward, backward)   |   1.29152 |  0.00174647 |
|   9 | 2.7B (forward only)        |  0.416278 | 0.000982001 |

context length: 256, 0 warmup, 10 step:

|    | model                      |      mean |         std |
|---:|:---------------------------|----------:|------------:|
|  0 | small (forward, backward)  | 0.0621514 | 0.000148466 |
|  1 | small (forward only)       | 0.0206247 | 0.000277217 |
|  2 | medium (forward, backward) | 0.189973  | 0.00113511  |
|  3 | medium (forward only)      | 0.0623993 | 0.00146085  |
|  4 | large (forward, backward)  | 0.419589  | 0.00279662  |
|  5 | large (forward only)       | 0.138054  | 0.000607349 |
|  6 | xl (forward, backward)     | 0.868489  | 0.00664378  |
|  7 | xl (forward only)          | 0.280147  | 0.000998939 |
|  8 | 2.7B (forward, backward)   | 1.28705   | 0.00800176  |
|  9 | 2.7B (forward only)        | 0.415899  | 0.000786901 |
context length: 256, 1 warmup, 10 step:

|     | model                      |      mean |         std |
| --: | :------------------------- | --------: | ----------: |
|   0 | small (forward, backward)  | 0.0622305 | 1.54034e-05 |
|   1 | small (forward only)       | 0.0205558 | 4.43533e-05 |
|   2 | medium (forward, backward) |  0.190285 | 0.000356011 |
|   3 | medium (forward only)      | 0.0616729 | 4.77538e-05 |
|   4 | large (forward, backward)  |  0.420813 |  0.00117447 |
|   5 | large (forward only)       |   0.13763 | 0.000256597 |
|   6 | xl (forward, backward)     |  0.869407 |  0.00173174 |
|   7 | xl (forward only)          |  0.281927 | 0.000557371 |
|   8 | 2.7B (forward, backward)   |   1.29001 |  0.00227628 |
|   9 | 2.7B (forward only)        |  0.416239 | 0.000703225 |
> [!answer]
> from 60ms to 1~2s, no warmup seem no significant difference. Maybe the optimize is not radical.

---

## NSYS Profile

context length: 128, 2 warmup, 10 step:

|    | model   |      mean |         std |
|---:|:--------|----------:|------------:|
|  0 | small   | 0.0803011 | 0.00212902  |
|  1 | medium  | 0.165493  | 0.000958763 |
|  2 | large   | 0.316326  | 0.000466201 |
|  3 | xl      | 0.626747  | 0.000308674 |
|  4 | 2.7B    | 0.967584  | 0.00021102  |

---

## Mixed Precision

```
def main():
    s = torch.tensor(0, dtype=torch.float32)
    for i in range(1000):
        s += torch.tensor(0.01, dtype=torch.float32)
    print(s)

    s = torch.tensor(0, dtype=torch.float16)
    for i in range(1000):
        s += torch.tensor(0.01, dtype=torch.float16)
    print(s)

    s = torch.tensor(0, dtype=torch.float32)
    for i in range(1000):
        s += torch.tensor(0.01, dtype=torch.float16)
    print(s)

    s = torch.tensor(0, dtype=torch.float32)
    for i in range(1000):
        x = torch.tensor(0.01, dtype=torch.float16)
        s += x.to(torch.float32)
    print(s)
```

```
tensor(10.0001)
tensor(9.9531, dtype=torch.float16)
tensor(10.0021)
tensor(10.0021)
```

> [!note]
> 纯 fp16 误差最大，fp32+16次之，注意创建的时候是16就会有点误差，32+32误差 最小
> > - 第一行（float32 累加 float32）误差非常小，绝对误差大约在 1e-7 ~ 1e-4 量级，典型值约 2e-7（几乎等于 10.0，可视为精确到打印位）。
> > - 第二行（float16 累加 float16）误差很大，绝对误差可能在 0.1 ~ 0.5 的量级；我估算最终值大约在 9.56 附近，故与精确 10 的误差约 0.44（这是由于 float16 在较大和值域时步长（ULP）变粗造成的累计离散化）。
> > - 第三行（s 为 float32，但每次加的是 float16 张量 —— 隐式上转换到 float32）：每步使用的是 float16 能表示的 0.01 的近似值（≈0.0100021），总和约 1000 * 0.0100021 ≈ 10.0021，误差约 +2×10^-3。
> > - 第四行（和第三行等价，显式把 x.to(torch.float32)）：结果与第三行几乎相同，误差约 +2×10^-3。


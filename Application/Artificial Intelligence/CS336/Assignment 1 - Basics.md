> [!question]
> What Unicode character does `chr(0)` return?

> [!answer]
> `\0`

> [!question]
> How does this character's string representation (`__repr__`)  differ from its printed representation?

> [!answer]
> ```python
> >>> print(repr(empty))
> '\x00'
> >>> print(empty)
>
> >>> 
> ```

> [!question]
> What happens when this character occurs in text? It may be helpful to play around with the following in your Python interpreter and see if it matches your expectations:

> [!answer]
> ```python
> >>> chr(0)
> '\x00'
> >>> print(chr(0))
> 
> >>> "this is a test" + chr(0) + "string"
> 'this is a test\x00string'
> >>> print("this is a test" + chr(0) + "string")
> this is a teststring
> >>> 
> ```

---

> [!question]
> What are some reasons to prefer training our tokenizer on UTF-8 encoded bytes, rather than UTF-16 or UTF-32? It may be helpful to compare the output of these encodings for various input strings.


> [!answer]
> 变长编码，节约空间，越常出现的字符越短，效率更高

```python
>>> str="测试字符串, testing string"
>>> str.encode("utf-8")
b'\xe6\xb5\x8b\xe8\xaf\x95\xe5\xad\x97\xe7\xac\xa6\xe4\xb8\xb2, testing string'
>>> str.encode("utf-16")
b'\xff\xfeKm\xd5\x8bW[&{2N,\x00 \x00t\x00e\x00s\x00t\x00i\x00n\x00g\x00 \x00s\x00t\x00r\x00i\x00n\x00g\x00'
>>> str.encode("utf-32")
b'\xff\xfe\x00\x00Km\x00\x00\xd5\x8b\x00\x00W[\x00\x00&{\x00\x002N\x00\x00,\x00\x00\x00 \x00\x00\x00t\x00\x00\x00e\x00\x00\x00s\x00\x00\x00t\x00\x00\x00i\x00\x00\x00n\x00\x00\x00g\x00\x00\x00 \x00\x00\x00s\x00\x00\x00t\x00\x00\x00r\x00\x00\x00i\x00\x00\x00n\x00\x00\x00g\x00\x00\x00'
>>> len(str.encode("utf-8")
... )
31
>>> len(str.encode("utf-16"))
44
>>> len(str.encode("utf-32"))
88
>>>
```

> [!question] unicode2
> Consider the following (incorrect) function, which is intended to decode a UTF-8 byte string into a Unicode string. Why is this function incorrect? Provide an example of an input byte string that yields incorrect results.

```python
def decode_utf8_bytes_to_str_wrong(bytestring: bytes):
	return "".join([bytes([b]).decode("utf-8") for b in bytestring])
```

> [!answer]
> decode concatenated byte string is different from decoding each byte string and then concatenate them.

> [!question] train_bpe
> Implement `train_bpe`, pass `tests/test_train_bpe.py`
> Then train on TinyStories/OWT

> [!answer]
> passed

> [!question] tokenizer
> Implement `Tokenizer`, pass `tests/test_tokenizer.py`

> [!answer]
> passed

> [!question] tokenizer_experiments
> + Sample 10 documents from TinyStories and OpenWebText. Using your previously-trained TinyS- tories and OpenWebText tokenizers (10K and 32K vocabulary size, respectively), encode these sampled documents into integer IDs. What is each tokenizer’s compression ratio (bytes/token)?
> + What happens if you tokenize your OpenWebText sample with the TinyStories tokenizer? Com- pare the compression ratio and/or qualitatively describe what happens.
> + Estimate the throughput of your tokenizer (e.g., in bytes/second). How long would it take to tokenize the Pile dataset (825GB of text)?
> + Using your TinyStories and OpenWebText tokenizers, encode the respective training and devel- opment datasets into a sequence of integer token IDs. We’ll use this later to train our language model. We recommend serializing the token IDs as a NumPy array of datatype uint16. Why is uint16 an appropriate choice?

> [!answer]
> + about 4.1~4.2, 10k is almost same as 32k
> + The compression ratio will decrease
> + 2.5M bytes/s, about 102 hours (pref: 4k -> 2.5M)

![[cs336-a1-math-notations.png]]

![[cs336-a1-initialize.png]]

> [!question] linear/embedding
> implement the linear module, and pass `pytest -k test_linear`
> implement the embedding module, and pass `pytest -k test_embedding`

---
Resource Accounting of Transformer LM:
$B$: batch size
$L$: sequence len
$H$: num heads
$D$: model dim
$D_{ff}$: model ff dim
$N$: num layers
$V$: vocab size
1. Embeddings: $0$
2. TransformerBlock:
	1. `qkv_proj`: $3\times 2\times B \times L\times D^2=6BLD^2$
	2. `attn`: $2 \times H\times B \times L^2 \times \dfrac{D}{H}+2\times H \times B \times L^2\times \dfrac{D}{H}=4BDL^2$
	3. `o_proj`: $2 \times B\times L\times D^2=2BLD^2$
	4. `ffn`: $2\times B\times L\times D\times D_{ff}\times 2+2\times B\times L\times D\times {D_{ff}}=6BLD D_{ff}$
	sum: $((8BLD^2+4BDL^2)+6 BLD D_{ff})\times N$
3. Final: $2BLDV$
> [!question]
> Consider GPT-2 XL, which has the following configuration:
> ```
> vocab_size: 50257
> context_length: 1024
> num_layers: 48
> d_model: 1600
> num_heads: 25
> d_ff: 6400
> ```
> Suppose we constructed our model using this configuration. How many trainable parameters would our model have? Assuming each parameter is represented using single-precision floating point, how much memory is required to just load this model?

> [!answer]
> 2127057600
> $2127057600\times 4\text{ Bytes}=8508230400\text{ Bytes}=7.9\text{ GB}$

> [!question]
> Identify the matrix multiplies required to complete a forward pass of our GPT-2 XL-shaped model. How many FLOPs do these matrix multiplies require in total? Assume that our input sequence has `context_length` tokens.

> [!answer]
> For every Transformer Block:
> 1. qkv_proj: $6BLD^2=15728640000$
> 2. attn: $4BDL^2=6710886400$
> 3. o_proj: $2BLD^2=5242880000$
> 4. ffn: $6BLD D_{ff}=62914560000$
> sum: $90596966400$
> All Blocks: $4348654387200$
> Final Layer: $2BLDV=164682137600$
> Total: $4513336524800$

> [!question]
> Based on your analysis above, which parts of the model require the most FLOPs?

> [!answer]
> FFN

> [!question]
> Repeat your analysis with GPT-2 small (12 layers, 768 d_model, 12 heads), GPT-2 medium (24 layers, 1024 d_model, 16 heads), and GPT-2 large (36 layers, 1280 d_model, 20 heads). As the model size increases, which parts of the Transformer LM take up proportionally more or less of the total FLOPs?

> [!answer]
> ```
> GPT2-XL | 4513336524800 | attn: 1328755507200/29.44%    ffn: 3019898880000/66.91%       output: 164682137600/3.65%
> GPT2-Large | 2257754521600 | attn: 676457349120/29.96%  ffn: 1449551462400/64.20%       output: 131745710080/5.84%
> GPT2-Medium | 1033109504000 | attn: 309237645312/29.93% ffn: 618475290624/59.87%        output: 105396568064/10.20%
> GPT2-Small | 349630365696 | attn: 96636764160/27.64%    ffn: 173946175488/49.75%        output: 79047426048/22.61%
> ```
> The larget model is, the more proportion does ffn takes in a pass

> [!question]
> Take GPT-2 XL and increase the context length to 16,384. How does the total FLOPs for one forward pass change? How do the relative contribution of FLOPs of the model components change?

> [!answer]
> `GPT2-XL-large-context | 149522795724800 | attn: 98569499443200/65.92%   ffn: 48318382080000/32.32%      output: 2634914201600/1.76%`
> Attention becomes the most.

---

AdamW:
公式中 $1-\beta^t$ 的项是为了无偏估计，因为 EMA 会初始化为 $0$，导致值偏小

> [!question]
> Let us compute how much memory and compute running AdamW requires. Assume we are using float32 for every tensor

parameter size: $N$
mem for params: $4N$ (float32)
mem for adamW: $4N \times 2=8N$
mem for activations: depends on batch_size.

---

> [!question] Batch Size
> Vary your batch size all the way from 1 to the GPU memory limit. Try at least a few batch sizes in between, including typical sizes like 64 and 128.

> [!answer]
> larger batch size converges faster, while final result inferior than small batch_size results.
> ![[Pasted image 20250921172507.png]]

---

> [!question] best-lr

> [!answer]
> For `tiny` model, best is around 2e-3
> ![[Pasted image 20250921233913.png]]
> Too high lr causes diverge.

---
> [!question] Ablation: No RMSNorm
> Compare baseline(RMSNorm) with no-RMSNorm

> [!answer]
> Converge much slower, inferior result.
> ![[Pasted image 20250921233333.png]]


> [!question] Ablation: post-norm
> Compare baseline(pre-norm) with post-norm

> [!answer]
> Larger grad, less stability
> ![[Pasted image 20250921233436.png]]

> [!question] Ablation: silu
> Compare baseline (SwiGLU) with SiLU

> [!answer]
> converge slower
> ![[Pasted image 20250921233525.png]]


> [!question] Ablation: no-RoPE
> Compare baseline(RoPE) with NoPE

> [!answer]
> converge slower, and final result lower.
> ![[Pasted image 20250921233659.png]]


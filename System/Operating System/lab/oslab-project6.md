> [!question] 
> 请描述所设计的文件系统的磁盘使用布局

假设文件系统起始于 SD 卡的 512MB 处（扇区号 1048576），以 4KB 为一个数据块（Block），扇区大小为 512B。

| 区域名称            | 偏移 (扇区)    | 大小             | 说明                            |
| :-------------- | :--------- | :------------- | :---------------------------- |
| **Reserved**    | 0          | 1048576        | 内核镜像及保留区域 (0 - 512MB)         |
| **Superblock**  | 0 (相对FS起始) | 1 扇区 (512B)    | 存储文件系统元信息 (Magic, 大小, 偏移量等)   |
| **Block Map**   | 1          | 32 扇区 (16KB)   | 数据块位图，支持映射 128K 个块 (512MB 空间) |
| **Inode Map**   | 33         | 1 扇区 (512B)    | Inode 位图，支持 4096 个 Inode      |
| **Inode Table** | 34         | 512 扇区 (256KB) | Inode 数组，4096 个 Inode × 64B/个 |
| **Data Blocks** | 546        | 剩余空间           | 实际数据存储区域，按 4KB 对齐             |

> [!question]
> 请展示文件系统元数据的数据结构，包括superblock, inode, dentry, and file descriptor

**Superblock (超级块)**
```c
typedef struct {
    uint32_t magic;           // 幻数，例如 0x66666666
    uint32_t fs_size;         // 文件系统大小 (扇区数)
    uint32_t start_sector;    // 起始物理扇区号
    uint32_t root_inode;      // 根目录的 Inode 编号
    uint32_t block_map_offset;// Block Map 偏移 (扇区)
    uint32_t inode_map_offset;// Inode Map 偏移 (扇区)
    uint32_t inode_table_offset; // Inode Table 偏移 (扇区)
    uint32_t data_offset;     // 数据区偏移 (扇区)
    uint32_t inode_count;     // Inode 总数
    uint32_t block_count;     // 数据块总数
    uint8_t  pad[472];        // 填充至 512 字节
} superblock_t;
```

**Inode (索引节点)**
需支持 A-Core 的大文件（>128MB）要求，采用直接索引与间接索引结合。
```c
typedef struct {
    uint32_t mode;        // 文件类型 (目录/文件) 及权限
    uint32_t size;        // 文件大小 (字节)
    uint32_t link_count;  // 硬链接计数 (支持 ln 命令)
    uint32_t blocks;      // 占用块数
    uint32_t direct[10];  // 直接索引 (10 * 4KB = 40KB)
    uint32_t indirect;    // 一级间接索引 (1024 * 4KB = 4MB)
    uint32_t double_indirect; // 二级间接索引 (1024 * 1024 * 4KB = 4GB)
    uint32_t mtime;       // 修改时间 (可选)
    uint8_t  pad[4];      // 填充至 64 字节 (根据设计调整)
} inode_t;
```

**Dentry (目录项)**
```c
typedef struct {
    char name[28];        // 文件名 (固定长度，例如 28 字节)
    uint32_t inode_id;    // 对应的 Inode 编号
} dentry_t;               // 总大小 32 字节
```

**File Descriptor (文件描述符 - 内存结构)**
```c
typedef struct {
    uint32_t inode_id;    // 打开文件的 Inode 编号
    uint32_t pos;         // 当前读写指针偏移量
    uint32_t flags;       // 读写权限 (O_RDONLY, O_RDWR 等)
    uint32_t valid;       // 该描述符是否有效
} file_desc_t;
```

> [!question]
> 所设计的文件系统能支持多少文件和目录？

支持的文件和目录总数受限于 **Inode Map** 和 **Inode Table** 的大小。
*   **计算依据：** 在上述设计中，Inode Map 占用 1 个扇区（512 Bytes = 4096 bits）。
*   **结论：** 该文件系统最多支持 **4096** 个文件或目录（Inode 总数）。
*   **存储容量：** 若 Block Map 能够映射 512MB 空间，且支持二级间接索引，单文件最大理论可支持 4GB（受限于 32位 size 字段），系统总容量受限于 Block Map 覆盖范围。

> [!question]
> 请简述文件系统初始化时的流程

在内核启动阶段 (`kernel_main` 或文件系统初始化函数中)：

1.  **读取 Superblock：** 从 SD 卡预定的起始扇区（如 1048576）读取 512 字节。
2.  **校验幻数：** 检查读取数据的 `magic` 字段是否为 `0x66666666`。
    *   **若合法 (文件系统存在)：**
        *   将 Superblock 信息加载到内存。
        *   根据偏移量将 Block Map 和 Inode Map 部分或全部读入内存（C-Core 可在此处初始化 Cache）。
        *   打印 `statfs` 信息（如任务书图 P6-5）。
    *   **若非法 (文件系统不存在)：**
        *   执行 `mkfs` 逻辑。
        *   **清空位图：** 将 Block Map 和 Inode Map 区域置 0。
        *   **写入 Superblock：** 初始化元数据并写入磁盘。
        *   **创建根目录：** 分配 Root Inode（通常为 ID 1），分配一个数据块，写入 `.` (指向自身) 和 `..` (指向自身) 两个目录项。
        *   将初始化的数据回写到 SD 卡，完成格式化。

> [!question]
> 请描述如何完成一个ls命令进行路径查询，例如 `ls /home/student`

1.  **获取根目录 Inode：** 从 Superblock 中获取根目录 Inode 编号 (Root Inode)。
2.  **解析路径第一级 `/home`：**
    *   读取 Root Inode 指向的数据块（利用 C-Core 的 Page Cache 读取）。
    *   遍历数据块中的 `dentry_t` 数组，匹配名称字符串 `"home"`。
    *   找到匹配项，获取其对应的 `inode_id` (设为 `inode_home`)。
3.  **解析路径第二级 `/student`：**
    *   读取 `inode_home` 指向的数据块。
    *   遍历目录项，匹配名称字符串 `"student"`。
    *   找到匹配项，获取其对应的 `inode_id` (设为 `inode_student`)。
4.  **读取目标目录内容：**
    *   读取 `inode_student` 的元数据，确认其为目录类型。
    *   读取该 Inode 指向的所有数据块。
5.  **输出结果：**
    *   遍历读取到的数据块中的所有有效 `dentry_t`。
    *   打印每个 entry 的 `name`。
    *   (若为 `ls -l`) 根据 entry 中的 `inode_id` 读取对应的 Inode 信息，打印大小、链接数等属性。
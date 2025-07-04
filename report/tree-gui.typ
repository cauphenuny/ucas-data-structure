#import "meta.typ": *
== CLI

=== 功能介绍

```bash
$ build/balanced_tree
commands:
    [q]uit
    [h]elp

    [c]reate <tree-id: a-z|A-Z> <algo: basic|avl|treap|splay>
    [d]elete <tree-id>
    [p]rint <tree-id>*
    [l]ist

    [i]nsert <tree-id> <key: int> <value: int>
    [r]emove <tree-id> <key: int>
    [f]ind <tree-id> <key: int>

    [s]plit <dest-id> <src-id> <key: int>
    [m]erge <dest-id> <src-id>

    [R]andom_insert <tree-id> <count: int>
    [S]equential_insert <tree-id> <start: int> <end: int>

trace mode:
    [n]: next
    [c]: auto continue
```

我们实现了一个功能强大的解释器环境

支持创建/删除/输出树，在树中插入/删除/查找节点，分割树，合并树。

树名为单个字母 (a-z, A-Z)，可以使用任意算法 (basic: 普通BST, avl: AVLTree, treap: Treap, splay: Splay) 创建树

命令可以写全，也可以只写第一个字符

支持随机插入和顺序插入若干个节点。

在每一个操作之后都会打印单步结果 (trace)，对树结构的任何操作（例如：连接或者断开连接子树）都会被实时记录下来。

显示 trace 时支持自动继续 (c) 和单步执行 (n)。

---

实现了一个语法糖，从而能够像使用主流编程语言一样使用这个解释器，能够很大程度上提高可读性

```cpp
>>> A = avl.create()
>>> A.SequentialInsert(1, 10)
>>> B = A.split(5)
>>> B.print()
>>> print
>>> B.merge(A)
>>> print()
>>> delete(B)
```

等价于

```bash
>>> create A avl
>>> S A 1 10
>>> s B A 5
>>> p B
>>> p
>>> m B A
>>> p
>>> d B
```

---

使用示例：

#grid(
  columns: (1fr, 1fr),
  [
    - 插入/删除/查找
    ```bash
    >>> c A avl # create an AVLTree A
    Created tree A with algorithm avl
    >>> i A 1 10 # insert key-value 1-10 to tree A
    Inserted {1: 10} into tree A
    ------------
    Trace of tree A:
    #1:
    {1: 10}
    >>> f A 1
    Found {1: 10} in tree A
    >>> i A 2 20
    Inserted {2: 20} into tree A
    ------------
    Trace of tree A:
    #1:
        {2: 20}
    {1: 10}
    ```
  ],
  [
    ```bash
    >>> i A 3 30 # insert cause imbalance, see trace!
    Inserted {3: 30} into tree A
    ------------
    Trace of tree A:
    #1:
            {3: 30}
        {2: 20}
    {1: 10}
    ------------
    (trace) c
    #2:
    {1: 10}
    ----
        {3: 30}
    {2: 20}
    ------------
    #3:
        {3: 30}
    {2: 20}
        {1: 10}
    ```
  ],
)

---

```bash
>>> S A 4 12
Inserted sequential elements from 4 to 12 into tree A
...
>>> r A 6
Removed 6 from tree A
```
#let grid2(a, b) = grid(
  columns: (1fr, 1fr),
  a, b,
)
#grid2[
  ```bash
  ------------
  Trace of tree A:
  #1:
              {11: 92}
          {10: 25}
              {9: 100}
      {8: 28}
              {7: 84}
          {6: 71}
  {4: 85}
          {3: 30}
      {2: 20}
          {1: 10}
  ----
  {5: 5}
  ------------
  (trace) c
  ```
][
  ```bash
  #2:
              {11: 92}
          {10: 25}
              {9: 100}
      {8: 28}
          {6: 71}
  {4: 85}
          {3: 30}
      {2: 20}
          {1: 10}
  ----
  {5: 5}
  ----
  {7: 84}
  ------------
  ```
]

---

#grid2[
  ```bash
  #3:
              {11: 92}
          {10: 25}
              {9: 100}
      {8: 28}
          {6: 71}
  {4: 85}
          {3: 30}
      {2: 20}
          {1: 10}
  ----
      {7: 84}
  {5: 5}
  ------------
  ```
][
  ```bash
  #4:
              {11: 92}
          {10: 25}
              {9: 100}
      {8: 28}
  {4: 85}
          {3: 30}
      {2: 20}
          {1: 10}
  ----
      {7: 84}
  {5: 5}
  ----
  {6: 71}
  ------------
  ```
]


---

#grid2[
  ```bash
  #5:
              {11: 92}
          {10: 25}
              {9: 100}
      {8: 28}
  {4: 85}
          {3: 30}
      {2: 20}
          {1: 10}
  ----
      {7: 84}
  {5: 5}
  ------------
  ```
][
  ```bash
  #6:
              {11: 92}
          {10: 25}
              {9: 100}
      {8: 28}
              {7: 84}
          {5: 5}
  {4: 85}
          {3: 30}
      {2: 20}
          {1: 10}
  >>>
  ```
]

---

- 分裂：在$O(log n)$ 时间内分裂出 $>= "key"$ 的所有节点到一颗新树

```bash
>>> S A 10 20 # insert [10, 20) to tree A
...
>>> p
Tree A: AVLTree:
                {19: 116}
            {18: 139}
                {17: 173}
        {16: 187}
            {15: 159}
    {14: 143}
                {13: 169}
            {12: 160}
                {11: 195}
        {10: 124}
                {3: 30}
            {2: 20}
                {1: 10}
```

---

```bash
>>> s B A 15 # split tree A at key 15, result in tree B
...
>>> p
Tree A: AVLTree:
            {14: 143}
                {13: 169}
        {12: 160}
            {11: 195}
    {10: 124}
            {3: 30}
        {2: 20}
            {1: 10}
Tree B: AVLTree:
            {19: 116}
        {18: 139}
            {17: 173}
    {16: 187}
        {15: 159}
```

---

使用相同的命令管理不同算法的树

```bash
>>> c A avl
Created tree A with algorithm avl
>>> c T treap
Created tree T with algorithm treap
>>> c S splay
Created tree S with algorithm splay
>>> S A 1 10 # insert [1, 10) to tree A
...
>>> S T 1 10 # insert [1, 10) to tree T
...
>>> S S 1 10 # insert [1, 10) to tree S
...
>>> p ATS
Tree A: AVLTree:
                {9: 91}
            {8: 15}
                {7: 44}
        {6: 76}
            {5: 30}
    {4: 26}
            {3: 28}
        {2: 97}
            {1: 13}
Tree T: Treap:
                    {9: 33}
                {8: 98}
            {7: 51}
                {6: 94}
        {5: 67}
                {4: 94}
            {3: 98}
    {2: 21}
        {1: 61}
Tree S: SplayTree:
    {9: 14}
        {8: 27}
            {7: 92}
                {6: 47}
                    {5: 60}
                        {4: 13}
                            {3: 24}
                                {2: 62}
                                    {1: 54}
>>>
```


=== 实现

```cpp
    while (true) {
        std::cout << PROMPT;
        std::string line;
        if (!std::getline(std::cin, line)) {
            std::cout << msg[Ret::EXIT];
            break;
        }
        if (line.empty()) continue;
        auto [cmd, args] = parse(parse, line);
        char ch = '\0';
        std::istringstream cmd_iss(cmd), iss(args);
        cmd_iss >> ch;
        if (commands.contains(ch)) {
            auto ret = commands[ch](std::move(iss));
            std::cout << msg[ret];
            if (ret == Ret::EXIT) {
                break;
            }
        } else {
            std::cout << msg[Ret::INVALID];
        }
    }
```

通过预定义的 command handle 不断地处理每一个操作，十分简洁

`parse` 和 `commands` 的详细内容可以查看源代码

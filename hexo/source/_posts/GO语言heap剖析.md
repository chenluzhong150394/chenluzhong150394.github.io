title: GO语言heap剖析
desc: GO语言heap剖析
date: 2017-08-23 10:33:42
tags: [golang, heap]
categories: golang
---
<!-- more -->


## heap使用
在go语言的标准库container中，实现了三中数据类型：heap,list,ring，list在前面一篇文章中已经写了，现在要写的是heap（堆）的源码剖析。

首先，学会怎么使用heap，第一步当然是导入包了，代码如下：

```go
package main

import (
	"container/heap"
	"fmt"
)
```
这个堆使用的数据结构是最小二叉树，即根节点比左边子树和右边子树的所有值都小。源码里面只是实现了一个接口，它的定义如下：

```go
type Interface interface {
	sort.Interface
	Push(x interface{}) // add x as element Len()
	Pop() interface{}   // remove and return element Len() - 1.
}
```
从这个接口可以看出，其继承了sort.Interface接口，那么sort.Interface的定义是什么呢？源码如下：

```go
type Interface interface {
	// Len is the number of elements in the collection.
	Len() int
	// Less reports whether the element with
	// index i should sort before the element with index j.
	Less(i, j int) bool
	// Swap swaps the elements with indexes i and j.
	Swap(i, j int)
}
```
也就是说，我们要使用go标准库给我们提供的heap，那么必须自己实现这些接口定义的方法，需要实现的方法如下：

- Len() int
- Less(i, j int) bool
- Swap(i, j int)
- Push(x interface{})
- Pop() interface{}

实现了这五个方法的数据类型才能使用go标准库给我们提供的heap，下面简单示例为定义一个IntHeap类型，并实现上面五个方法。

```go
type IntHeap []int  // 定义一个类型

func (h IntHeap) Len() int { return len(h) }  // 绑定len方法,返回长度
func (h IntHeap) Less(i, j int) bool {  // 绑定less方法
	return h[i] < h[j]  // 如果h[i]<h[j]生成的就是小根堆，如果h[i]>h[j]生成的就是大根堆
}
func (h IntHeap) Swap(i, j int) {  // 绑定swap方法，交换两个元素位置
	h[i], h[j] = h[j], h[i]
}

func (h *IntHeap) Pop() interface{} {  // 绑定pop方法，从最后拿出一个元素并返回
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[0 : n-1]
	return x
}

func (h *IntHeap) Push(x interface{}) {  // 绑定push方法，插入新元素
	*h = append(*h, x.(int))
}
```
针对IntHeap实现了这五个方法之后，我们就可以使用heap了，下面是具体使用方法：

```go
func main() {
	h := &IntHeap{2, 1, 5, 6, 4, 3, 7, 9, 8, 0}  // 创建slice
	heap.Init(h)  // 初始化heap
	fmt.Println(*h)
	fmt.Println(heap.Pop(h))  // 调用pop
	heap.Push(h, 6)  // 调用push
	fmt.Println(*h)
	for len(*h) > 0 {
		fmt.Printf("%d ", heap.Pop(h))
	}

}
输出结果：
[0 1 3 6 2 5 7 9 8 4]
0
[1 2 3 6 4 5 7 9 8 6]
1 2 3 4 5 6 6 7 8 9 
```
上面就是heap的使用了。

## heap提供的方法
heap提供的方法不多，具体如下：

```go
h := &IntHeap{3, 8, 6}  // 创建IntHeap类型的原始数据
func Init(h Interface)  // 对heap进行初始化，生成小根堆（或大根堆）
func Push(h Interface, x interface{})  // 往堆里面插入内容
func Pop(h Interface) interface{}  // 从堆顶pop出内容
func Remove(h Interface, i int) interface{}  // 从指定位置删除数据，并返回删除的数据
func Fix(h Interface, i int)  // 从i位置数据发生改变后，对堆再平衡，优先级队列使用到了该方法
```

## heap源码剖析
heap的内部实现，是使用最小(最大)堆，索引排序从根节点开始，然后左子树，右子树的顺序方式。 内部实现的down和up分别表示对堆中的某个元素向下保证最小(最大)堆和向上保证最小(最大)堆。

当往堆中插入一个元素的时候，这个元素插入到最右子树的最后一个节点中，然后调用up向上保证最小(最大)堆。

当要从堆中推出一个元素的时候，先吧这个元素和右子树最后一个节点交换，然后弹出最后一个节点，然后对root调用down，向下保证最小(最大)堆。

好了，开始分析源码：

首先，在使用堆之前，必须调用它的Init方法，初始化堆，生成小根(大根)堆。Init方法源码如下:

```go
// A heap must be initialized before any of the heap operations
// can be used. Init is idempotent with respect to the heap invariants
// and may be called whenever the heap invariants may have been invalidated.
// Its complexity is O(n) where n = h.Len().
//
func Init(h Interface) {
	// heapify
	n := h.Len()  // 获取数据的长度
	for i := n/2 - 1; i >= 0; i-- {  // 从长度的一半开始，一直到第0个数据，每个位置都调用down方法，down方法实现的功能是保证从该位置往下保证形成堆
		down(h, i, n)
	}
}
```
接下来看down的源码：

```go
func down(h Interface, i0, n int) bool {
	i := i0  // 中间变量，第一次存储的是需要保证往下需要形成堆的节点位置
	for {  // 死循环
		j1 := 2*i + 1  // i节点的左子孩子
		if j1 >= n || j1 < 0 { // j1 < 0 after int overflow  // 保证其左子孩子没有越界
			break
		}
		j := j1 // left child  // 中间变量j先赋值为左子孩子，之后j将被赋值为左右子孩子中最小（大）的一个孩子的位置
		if j2 := j1 + 1; j2 < n && !h.Less(j1, j2) {
			j = j2 // = 2*i + 2  // right child
		}  // 这之后，j被赋值为两个孩子中的最小（大）孩子的位置（最小或最大由Less中定义的决定）
		if !h.Less(j, i) {
			break
		}  // 若j大于（小于）i，则终止循环
		h.Swap(i, j)  // 否则交换i和j位置的值
		i = j  // 令i=j，继续循环，保证j位置的子数是堆结构
	}
	return i > i0
}
```

这是建立堆的核心代码，其实，down并不能完全保证从某个节点往下每个节点都能保持堆的特性，只能保证某个节点的值如果不满足堆的性质，则将该值与其孩子交换，直到该值放到适合的位置，保证该值及其两个子孩子满足堆的性质。

但是，如果是通过Init循环调用down将能保证初始化后所有的节点都保持堆的特性，这是因为循环开始的`i := n/2 - 1`的取值位置，将会取到最大的一个拥有孩子节点的节点，并且该节点最多只有两个孩子，并且其孩子节点是叶子节点，从该节点往前每个节点如果都能保证down的特性，则整个列表也就符合了堆的性质了。

同样，有down就有up，up保证的是某个节点如果向上没有保证堆的性质，则将其与父节点进行交换，直到该节点放到某个特定位置保证了堆的性质。代码如下：


```go
func up(h Interface, j int) {
	for {  // 死循环
		i := (j - 1) / 2 // parent  // j节点的父节点
		if i == j || !h.Less(j, i) {  // 如果越界，或者满足堆的条件，则结束循环
			break
		}
		h.Swap(i, j)  // 否则将该节点和父节点交换
		j = i  // 对父节点继续进行检查直到根节点
	}
}
```

以上两个方法就是最核心的方法了，所有暴露出来的方法无非就是对这两个方法进行的封装。我们来看看以下这些方法的源码：

```go
func Push(h Interface, x interface{}) {
	h.Push(x)  // 将新插入进来的节点放到最后
	up(h, h.Len()-1)  // 确保新插进来的节点网上能保证堆结构
}

func Pop(h Interface) interface{} {
	n := h.Len() - 1  // 把最后一个节点和第一个节点进行交换，之后，从根节点开始重新保证堆结构，最后把最后那个节点数据丢出并返回
	h.Swap(0, n)
	down(h, 0, n)
	return h.Pop()
}

func Remove(h Interface, i int) interface{} {
	n := h.Len() - 1  pop只是remove的特殊情况，remove是把i位置的节点和最后一个节点进行交换，之后保证从i节点往下及往上都保证堆结构，最后把最后一个节点的数据丢出并返回
	if n != i {
		h.Swap(i, n)
		down(h, i, n)
		up(h, i)
	}
	return h.Pop()
}

func Fix(h Interface, i int) {
	if !down(h, i, h.Len()) {  // i节点的数值发生改变后，需要保证堆的再平衡，先调用down保证该节点下面的堆结构，如果有位置交换，则需要保证该节点往上的堆结构，否则就不需要往上保证堆结构，一个小小的优化
		up(h, i)
	}
}
```

以上就是go里面的heap所有的源码了，我也就不贴出完整版源码了，以上理解全部基于个人的理解，如有不当之处，还望批评指正。

## 利用heap实现优先级队列
既然用到了heap，那就用heap实现一个优先级队列吧，这个功能是很好的一个功能。
源码如下：

```go
package main

import (
	"container/heap"
	"fmt"
)

type Item struct {
	value    string // 优先级队列中的数据，可以是任意类型，这里使用string
	priority int    // 优先级队列中节点的优先级
	index    int    // index是该节点在堆中的位置
}

// 优先级队列需要实现heap的interface
type PriorityQueue []*Item

// 绑定Len方法
func (pq PriorityQueue) Len() int {
	return len(pq)
}

// 绑定Less方法，这里用的是小于号，生成的是小根堆
func (pq PriorityQueue) Less(i, j int) bool {
	return pq[i].priority < pq[j].priority
}

// 绑定swap方法
func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index, pq[j].index = i, j
}

// 绑定put方法，将index置为-1是为了标识该数据已经出了优先级队列了
func (pq *PriorityQueue) Pop() interface{} {
	old := *pq
	n := len(old)
	item := old[n-1]
	*pq = old[0 : n-1]
	item.index = -1
	return item
}

// 绑定push方法
func (pq *PriorityQueue) Push(x interface{}) {
	n := len(*pq)
	item := x.(*Item)
	item.index = n
	*pq = append(*pq, item)
}

// 更新修改了优先级和值的item在优先级队列中的位置
func (pq *PriorityQueue) update(item *Item, value string, priority int) {
	item.value = value
	item.priority = priority
	heap.Fix(pq, item.index)
}

func main() {
	// 创建节点并设计他们的优先级
	items := map[string]int{"二毛": 5, "张三": 3, "狗蛋": 9}
	i := 0
	pq := make(PriorityQueue, len(items)) // 创建优先级队列，并初始化
	for k, v := range items {             // 将节点放到优先级队列中
		pq[i] = &Item{
			value:    k,
			priority: v,
			index:    i}
		i++
	}
	heap.Init(&pq) // 初始化堆
	item := &Item{ // 创建一个item
		value:    "李四",
		priority: 1,
	}
	heap.Push(&pq, item)           // 入优先级队列
	pq.update(item, item.value, 6) // 更新item的优先级
	for len(pq) > 0 {
		item := heap.Pop(&pq).(*Item)
		fmt.Printf("%.2d:%s index:%.2d\n", item.priority, item.value, item.index)
	}
}

输出结果：
03:张三 index:-01
05:二毛 index:-01
06:李四 index:-01
09:狗蛋 index:-01
```


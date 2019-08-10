title: GO语言list剖析
desc: GO语言list剖析
date: 2017-08-23 10:33:42
tags: [golang, list]
categories: golang
---
<!-- more -->

## 使用方法
在GO语言的标准库中，提供了一个container包，这个包中提供了三种数据类型，就是heap,list和ring，本节要讲的是list的使用以及源码剖析。
要使用GO提供的list链表，则首先需要导入list包，如下所示：

```go
package main
import(
	"container/list"
)
```

导入包之后，需要了解list中定义了两种数据类型，Element和List，定义如下：

```go
// Element is an element of a linked list.
type Element struct {
    // Next and previous pointers in the doubly-linked list of elements.
    // To simplify the implementation, internally a list l is implemented
    // as a ring, such that &l.root is both the next element of the last
    // list element (l.Back()) and the previous element of the first list
    // element (l.Front()).
    next, prev *Element

    // The list to which this element belongs.
    list *List

    // The value stored with this element.
    Value interface{}
}

type List struct {
    root Element // sentinel list element, only &root, root.prev, and root.next are used
    len  int     // current list length excluding (this) sentinel element
}
```
Element里面定义了两个Element类型的指针next, prev以及List类型的指针list, Value用来存储值，List里面定义了一个Element作为链表的Root，len作为链表的长度。

import之后，就可以使用链表了：

```go
func main()  {
    list_test:=list.New()  // 创建list对象
    list_test.PushBack("123")  // 往List队列尾部插入数据
    list_test.PushBack("456")
    list_test.PushBack("789")
    fmt.Println(list_test.Len())  // 输出list长度
    fmt.Println(list_test.Front())  // 输出list第一个元素
    fmt.Println(list_test.Front().Next())  // 输出list第一个元素的下一个元素
    fmt.Println(list_test.Front().Next().Next())  // 输出list第三个元素
}
```

## list提供的方法
list提供的方法如下：

```go
type Element
    func (e *Element) Next() *Element
    func (e *Element) Prev() *Element
type List
    func New() *List
    func (l *List) Back() *Element   // 返回最后一个元素
    func (l *List) Front() *Element  // 返回第一个元素
    func (l *List) Init() *List  // 链表初始化
    func (l *List) InsertAfter(v interface{}, mark *Element) *Element // 在某个元素前插入
    func (l *List) InsertBefore(v interface{}, mark *Element) *Element  // 在某个元素后插入
    func (l *List) Len() int // 返回链表长度
    func (l *List) MoveAfter(e, mark *Element)  // 把e元素移动到mark之后
    func (l *List) MoveBefore(e, mark *Element)  // 把e元素移动到mark之前
    func (l *List) MoveToBack(e *Element) // 把e元素移动到队列最后
    func (l *List) MoveToFront(e *Element) // 把e元素移动到队列最头部
    func (l *List) PushBack(v interface{}) *Element  // 在队列最后插入元素
    func (l *List) PushBackList(other *List)  // 在队列最后插入接上新队列
    func (l *List) PushFront(v interface{}) *Element  // 在队列头部插入元素
    func (l *List) PushFrontList(other *List) // 在队列头部插入接上新队列
    func (l *List) Remove(e *Element) interface{} // 删除某个元素
```

## 源码剖析
首先，使用list.New()方法，返回的是一个List对象的指针，源码```func New() *List { return new(List).Init() }```并执行了List对象的Init()方法对list进行初始化，初始化root的prev和next指针以及list的长度。
之后调用list_test.PushBack("123")在队列尾部插入元素123，源码如下：

```go
func (l *List) PushBack(v interface{}) *Element {
	l.lazyInit()
	return l.insertValue(v, l.root.prev)
}
```
调用lazyInit(),如果链表没有初始化，则先初始化一遍，之后，调用list的insertValue方法，insertValue方法初始化节点之后，调用insert方法进行插入链表。

```go
func (l *List) insertValue(v interface{}, at *Element) *Element {
	return l.insert(&Element{Value: v}, at)
}
```
整篇文章最精髓的地方就在insert方法中了，源码如下：

```go
func (l *List) insert(e, at *Element) *Element {
	n := at.next  // 用中间变量n保存at节点的next指针
	at.next = e  // at节点的next指向要插入的节点
	e.prev = at  // 要插入的节点e的prev指向at节点
	e.next = n  // e的next节点指向中间变量n保存的指针
	n.prev = e  // at节点的下一个节点的prev指向e节点
	e.list = l  // e节点的list指向链表的root节点
	l.len++  // 链表的长度加一
	return e  // 返回刚插入节点的指针
}
```
这里的链表结构是双向链表，并且在root节点的prev指针指向了链表的结尾，链表结尾的next指针也指向了root节点，这样，其实形成了一个环形结构，如果是向链表的尾部插入新数据，则将root.prev传递给insert方法的at参数，如果是向头部插入，则将root传递给insert方法的at参数。

***这样做的好处是显而易见的，那就是从链表的尾部插入数据，将不需要遍历一遍链表，而只需要将root节点的prev传递给insert方法中就可以了，大大节省了从尾部插入节点的时间。这段代码我看了很久，觉得这个包中最精髓的地方也就在这了，这也是这篇文章诞生的原因。***

源码如下：

```go
// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Package list implements a doubly linked list.
//
// To iterate over a list (where l is a *List):
//	for e := l.Front(); e != nil; e = e.Next() {
//		// do something with e.Value
//	}
//
package list

// Element is an element of a linked list.
type Element struct {
	// Next and previous pointers in the doubly-linked list of elements.
	// To simplify the implementation, internally a list l is implemented
	// as a ring, such that &l.root is both the next element of the last
	// list element (l.Back()) and the previous element of the first list
	// element (l.Front()).
	next, prev *Element

	// The list to which this element belongs.
	list *List

	// The value stored with this element.
	Value interface{}
}

// Next returns the next list element or nil.
func (e *Element) Next() *Element {
	if p := e.next; e.list != nil && p != &e.list.root {
		return p
	}
	return nil
}

// Prev returns the previous list element or nil.
func (e *Element) Prev() *Element {
	if p := e.prev; e.list != nil && p != &e.list.root {
		return p
	}
	return nil
}

// List represents a doubly linked list.
// The zero value for List is an empty list ready to use.
type List struct {
	root Element // sentinel list element, only &root, root.prev, and root.next are used
	len  int     // current list length excluding (this) sentinel element
}

// Init initializes or clears list l.
func (l *List) Init() *List {
	l.root.next = &l.root
	l.root.prev = &l.root
	l.len = 0
	return l
}

// New returns an initialized list.
func New() *List { return new(List).Init() }

// Len returns the number of elements of list l.
// The complexity is O(1).
func (l *List) Len() int { return l.len }

// Front returns the first element of list l or nil.
func (l *List) Front() *Element {
	if l.len == 0 {
		return nil
	}
	return l.root.next
}

// Back returns the last element of list l or nil.
func (l *List) Back() *Element {
	if l.len == 0 {
		return nil
	}
	return l.root.prev
}

// lazyInit lazily initializes a zero List value.
func (l *List) lazyInit() {
	if l.root.next == nil {
		l.Init()
	}
}

// insert inserts e after at, increments l.len, and returns e.
func (l *List) insert(e, at *Element) *Element {
	n := at.next
	at.next = e
	e.prev = at
	e.next = n
	n.prev = e
	e.list = l
	l.len++
	return e
}

// insertValue is a convenience wrapper for insert(&Element{Value: v}, at).
func (l *List) insertValue(v interface{}, at *Element) *Element {
	return l.insert(&Element{Value: v}, at)
}

// remove removes e from its list, decrements l.len, and returns e.
func (l *List) remove(e *Element) *Element {
	e.prev.next = e.next
	e.next.prev = e.prev
	e.next = nil // avoid memory leaks
	e.prev = nil // avoid memory leaks
	e.list = nil
	l.len--
	return e
}

// Remove removes e from l if e is an element of list l.
// It returns the element value e.Value.
func (l *List) Remove(e *Element) interface{} {
	if e.list == l {
		// if e.list == l, l must have been initialized when e was inserted
		// in l or l == nil (e is a zero Element) and l.remove will crash
		l.remove(e)
	}
	return e.Value
}

// PushFront inserts a new element e with value v at the front of list l and returns e.
func (l *List) PushFront(v interface{}) *Element {
	l.lazyInit()
	return l.insertValue(v, &l.root)
}

// PushBack inserts a new element e with value v at the back of list l and returns e.
func (l *List) PushBack(v interface{}) *Element {
	l.lazyInit()
	return l.insertValue(v, l.root.prev)
}

// InsertBefore inserts a new element e with value v immediately before mark and returns e.
// If mark is not an element of l, the list is not modified.
func (l *List) InsertBefore(v interface{}, mark *Element) *Element {
	if mark.list != l {
		return nil
	}
	// see comment in List.Remove about initialization of l
	return l.insertValue(v, mark.prev)
}

// InsertAfter inserts a new element e with value v immediately after mark and returns e.
// If mark is not an element of l, the list is not modified.
func (l *List) InsertAfter(v interface{}, mark *Element) *Element {
	if mark.list != l {
		return nil
	}
	// see comment in List.Remove about initialization of l
	return l.insertValue(v, mark)
}

// MoveToFront moves element e to the front of list l.
// If e is not an element of l, the list is not modified.
func (l *List) MoveToFront(e *Element) {
	if e.list != l || l.root.next == e {
		return
	}
	// see comment in List.Remove about initialization of l
	l.insert(l.remove(e), &l.root)
}

// MoveToBack moves element e to the back of list l.
// If e is not an element of l, the list is not modified.
func (l *List) MoveToBack(e *Element) {
	if e.list != l || l.root.prev == e {
		return
	}
	// see comment in List.Remove about initialization of l
	l.insert(l.remove(e), l.root.prev)
}

// MoveBefore moves element e to its new position before mark.
// If e or mark is not an element of l, or e == mark, the list is not modified.
func (l *List) MoveBefore(e, mark *Element) {
	if e.list != l || e == mark || mark.list != l {
		return
	}
	l.insert(l.remove(e), mark.prev)
}

// MoveAfter moves element e to its new position after mark.
// If e or mark is not an element of l, or e == mark, the list is not modified.
func (l *List) MoveAfter(e, mark *Element) {
	if e.list != l || e == mark || mark.list != l {
		return
	}
	l.insert(l.remove(e), mark)
}

// PushBackList inserts a copy of an other list at the back of list l.
// The lists l and other may be the same.
func (l *List) PushBackList(other *List) {
	l.lazyInit()
	for i, e := other.Len(), other.Front(); i > 0; i, e = i-1, e.Next() {
		l.insertValue(e.Value, l.root.prev)
	}
}

// PushFrontList inserts a copy of an other list at the front of list l.
// The lists l and other may be the same.
func (l *List) PushFrontList(other *List) {
	l.lazyInit()
	for i, e := other.Len(), other.Back(); i > 0; i, e = i-1, e.Prev() {
		l.insertValue(e.Value, &l.root)
	}
}
```



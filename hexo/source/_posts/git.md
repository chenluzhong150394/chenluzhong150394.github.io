---
title: Git的安装及常用操作
date: 2019-08-10 13:52:50
tags: git操作
---





# 安装git



## Linux下安装

yum安装

~~~powershell
yum -y install git
~~~



## windows下安装

官网地址：

https://git-scm.com/download

![1553220095452](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553220095452.png)



![1553208779674](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553208779674.png)



下载到本地磁盘

![1553208790623](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553208790623.png)

安装

![1553208801316](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553208801316.png)



一路【next】就可以了

![1553220218170](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553220218170.png)

![1553220208875](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553220208875.png)



![1553220240618](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553220240618.png)

注意：**openssl  一定选它**

安装完成后，右击菜单栏，有如下菜单，表示安装完成

![1553220425466](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553220425466.png)



进入git bash选项
![1553220553963](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553220553963.png)





Git工作区、暂存区和版本库

![1553208888303](G:/%E8%A7%86%E9%A2%91/python%E7%AC%AC%E5%9B%9B%E6%9C%9F%E7%9A%84%E8%A7%86%E9%A2%91/day069/assets/1553208888303.png)







# git的使用



## 本地使用git管理代码



### git项目仓库的本地搭建

~~~
cd进入到自己希望存储代码的目录路径，并创建本地仓库.git
新创建的本地仓库.git是个空仓库

  cd 目录路径
  git init gitdemo  # 如果没有声明目录,则自动把当前目录作为git仓库
~~~



checkout 切换分支

pull 		拉取远程git代码



branch  -a  查看所有分支







## 管理远程git仓库



### 删除远端git项目中的指定文件和目录



 **首先拉取远程git仓库**

~~~python
##如果本地仓库存在，则只需要pull 将远端git仓库与本地git仓库一直
git pull


##如果本地仓库不存在，则需要克隆clone
git clone https://gitee.com/chenluzhong/blog.git
~~~



**使用git删除本地文件或目录**

~~~python
## 删除本地文件
git rm <file_name>

## 删除本地目录
### -r 参数是递归删除的意思，如果目录是空的，就不用加这个参数也可以    
git rm -r <dir_name>
~~~



**提交代码到本地仓库**

~~~python
git commit -m '删除某文件后的版本'
~~~



**将本地仓库推送到远端**

~~~python
git push <base_url> -u 
~~~









## 本地仓库推送到码云

首先码云仓库的地址是:  **https://gitee.com/chenluzhong/lufeiapi.git**



设置全局配置(用户名和邮箱)

~~~
git config --global user.name 'chenluzhong'
git config --global user.email '18438128833@163.com'
~~~

创建git仓库

~~~
git init
~~~

提交本地的文件到暂存区

~~~
git add .
~~~

将暂存区的内容提交到本地仓库中

~~~
git commit -m '这是第一个版本'
~~~

然后关联远程仓库地址

~~~
git remote add origin https://gitee.com/chenluzhong/lufeiapi.git
~~~

将本地的主分支与远程的分支进行关联

~~~
git branch --set-upstream-to=origin/master master
git pull orgin master 
~~~

将本地仓库推送到远端仓库

~~~
## -u 参数指定唯一主机,     master代表将推送到目标仓库的master主分支
$ git push <远程主机名> <本地分支名>:<远程分支名>

git push -u origin master:master
~~~







## branch分支操作

查看所有分支

- 查看本地分支

  ~~~
  git branch
  ~~~

- 查看远程分支

  ~~~
  git branch -a 
  ~~~

创建分支

~~~
git branch dev 	##新建一个dev的本地分支
~~~

切换分支

~~~
git checkout dev 	## 切换到dev这个分支
~~~

删除分支

- 删除本地分支

  ~~~
  git branch -d dev	## 删除本地分支   
  ~~~

- 删除远程分支

  ~~~
  git push origin --delete dev	## 删除远程仓库中dev分支
  ~~~


































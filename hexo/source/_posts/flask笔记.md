---
title: flask笔记
date: 2019-08-10 13:52:50
tags: flask框架
---


### FLASK 安装



先创建一个虚拟环境，并使用pycharm 初始化一个pure python项目

~~~python
mkvirtualenv  flask_demo -p python3 
~~~

~~~powershell
pip install flask==0.12.4
~~~



flask的简单组成

初始化flask  ==》  路由



创建一个flask 应用

~~~python
## 创建flask 应用
app = Flask(__name__)
~~~





路由-限定请求方式

~~~python
@app.route('/')
def  idnex():
	return '这里是首页'


##路由-限定请求方式
## route 中有个参数methods 是定义请求类型的，只有定义了才能访问，
#默认的是开启get的
@app.route('/',methods=["get","post"])
def  idnex():
	return '这里是首页'
~~~



开启debug模式

~~~
DEBUG = True
~~~



在主文件导入配置文件

~~~python
class Config(object)
	DEBUG = True
	
app.config.from_object(Config)

## 最常用的方式是通过对象的方式， 通过导包，将配置文件加载
~~~



启动flask 

~~~python
app.run(host='localhost',port=8080,debug=true)
    # flask 内部作为一个基本的web框架，内置http服务器肯定有的。
    #运行flask 可以使用 app.run（）
    # host 服务器启动时绑定的域名
    #port 服务器启动时绑定的端口
    #debug 是否开启调试模式
~~~





### 简单的flask demo详解



##### 在路由中设置变量（传递参数-两种）

~~~python
## 使用'< >'  表示变量名，
##<int:变量名>表示限制变量的数据类型
@app.route("/user/<int:userid>")
def user(userid):
    return "用户个人中心%s" % userid

"""
限制参数类型
int:变量名     #当前路由内容只能是整型
float:变量名   #当前路由内容只能是 浮点数
path:变量名   #当前路由内容可以是任何内容
"""
~~~





#### 正则匹配路由

1.首先导入转换器基类

~~~python
from werkzeug.routing import BaseConverter
~~~

2.自定义转换器

~~~python
class RegexCover(BaseConverter):

    def __init__(self, map,*args):
        super(RegexCover,self).__init__(map)
        ## 正则参数
        self.regex = args[0]
~~~

3.将自定义的转换器添加到转换器字典中，并指定转换器使用的别名

~~~python
app.url_map.converters['regex']  = RegexCover
~~~

4.就可以通过正则去获取参数变量了

~~~python
## regex 后面跟一个元组，元祖里面是正则表达式，mobile是变量名
@app.route("/user/<regex('\d+'):mobile>")
def user(mobile):
    return "用户手机号%s" % mobile
~~~

##### 预定义正则匹配路由

###### 可以直接讲正则(regex)写死,然后直接用就行了

一般应用场景是 固定类型的正则（验证手机号的合法等等）

~~~python
## 声明一个固定转换器
class Mobileter(BaseConverter):
    regex = "1[3-9]\d{9}"
    
  ## 将上面的转化器注册到转化器字典中
app.url_map.converters['mobile']  = Mobileter

##使用自定义的转换器，
@app.route("/user/<mobile:mobile>")
def user(mobile):
    return "用户手机号%s" % mobile
~~~



#### 系统自带转换器

---



werkzeug.routing.py

~~~python
DEFAULT_CONVERTERS = {
    "default": UnicodeConverter,
    "string": UnicodeConverter,
    "any": AnyConverter,
    "path": PathConverter,
    "int": IntegerConverter,
    "float": FloatConverter,
    "uuid": UUIDConverter,
}

~~~



## http的请求与响应



在flask中导入 request 模块，用request模块去获取客户端提交的数据

常用的属性如下：

| 属性    | 说明                           | 类型           |
| ------- | ------------------------------ | -------------- |
| data    | 记录请求的数据，并转换为字符串 | *              |
| form    | 记录请求中的表单数据           | MultiDict      |
| args    | 记录请求中的查询参数           | MultiDict      |
| cookies | 记录请求中的cookie信息         | Dict           |
| headers | 记录请求中的请求头             | EnvironHeaders |
| method  | 记录请求使用的HTTP方法         | GET/POST       |
| url     | 记录请求的URL地址              | string         |
| files   | 记录请求上传的文件             | *              |
| json    | 记录请求的json数据             | json           |





#### 响应

---

Flask 默认支持两种响应方式

- 数据响应： 默认响应html，也可以返回json
- 页面响应：重定向  url_for

响应的时候，flask也支持自定义响应状态码

**响应html文本**

~~~python
## 路由
@app.route("/")
def index():
    # [默认支持]响应html文本
    return "<img src='https://palletsprojects.com/logo-large.png'>"
~~~



**返回JSON数据**

在flask中可以直接使用jsonify 生成一个json的响应

~~~python
from flask import Flask, request, jsonify

@app.route("/")
def index():
    # 也可以响应json格式代码
    data = [
        {"id":1,"username":"liulaoshi","age":18},
        {"id":2,"username":"liulaoshi","age":17},
        {"id":3,"username":"liulaoshi","age":16},
        {"id":4,"username":"liulaoshi","age":15},
    ]
    return jsonify(data)
~~~



#### 重定向

---

重定向到站外页面

~~~python
from flask import Flask,request,jsonify,redirect
@app.route("/")
def index():
    # 页面跳转响应

    return redirect('http://www.baidu.com')
~~~

重定向到自己写的视图函数

也可以直接填写自己的url路径

也可以使用url_for 生成指定视图函数所对应url

~~~python
@app.route("/user")
def user():
    # 页面跳转响应
    userid = None
    return 'userid %s' % userid

## 路由
@app.route("/")
def index():
    # 页面跳转响应
    return redirect(url_for('user'))  ## 这里的user 是上面的user函数
~~~



#### url_for

---

~~~python
#使用url_for可以实现视图方法之间的内部跳转
# url_for("视图方法名")
@app.route("/login")
def login():
    return redirect( url_for("index") )
~~~



#### 重定向到带有参数的视图函数

---

在url_for 函数中传入参数

~~~python
## 路由传递参数
@app.route("/user/<userid>")
def user(userid):
    # 页面跳转响应
    return 'userid %s' % userid

# 重定向
@app.route("/")
def index():
    # 使用url_for 生成指定视图函数所对应的url
    return redirect(url_for('user',userid=100))
~~~



#### 自定义状态码

---

在flask 中，可以很方便的返回自定义状态码，以实现不符合http协议的状态吗，例如：status code :666

~~~python
@app.route('/demo4')
def demo4():
    return '状态码为 666', 400
~~~





## 会话控制



实现状态保持的两种方式：

- 在客户端存储信息使用Cookie本地存储，token[jwt.,auth]
- 在服务器端存储信息使用Session，redis



#### 设置Cookie

flask框架提供了一个make_responce 函数来快速创建响应对象

~~~python
## 首先实例化一个make_responce对象，传入的参数是响应对象的主体
## 去给这个响应对象设置cookies， 传入key，value，过期时间
## 最后将这个对象retrun ge给客户端
@app.route("/")
def set_cookie():
    resp = make_response('this is set cookie')
    resp.set_cookie('usename','xiaoming',max_age=3600)
    return resp
~~~



#### 获取Cookie

~~~python
@app.route("/get")
def get_cookie():
    resp = request.cookies.get('username')
    return resp
~~~







### Session

---

在服务器段进行状态保存的方案就是Session

注意：Session依赖于Cookie，而且flask中使用session，需要配置SECRET_KEY 选项，否则报错

#### 设置session

~~~python
## 首先设置SECRET_KEY 
class Config(object):
    SECRET_KEY = '1231fddfds213'
app.config.from_object(Config)

## 然后从flask中导入session模块
from flask import session

## 定义视图函数
@app.route("/set")
def set():
    session['uname'] = 'xiaoming'
    return 'ok'
~~~



#### 获取session

~~~python
## 直接使用session.get(ket)这个函数取得存储的session
@app.route("/get")
def get():
    resp = session.get('uname')
    return res
~~~





## 上下文



#### flask中上下文的分为两种

上下文：即语境，语意，在程序中可以理解为在代码执行到某一时刻时，根据之前代码所做的操作以及下文即将要执行的逻辑，可以决定在当前时刻下可以使用到的变量，或者可以完成的事情。

Flask中有两种上下文，请求上下文(request context)和应用上下文(application context)。

Flask中上下文对象：相当于一个容器，保存了 Flask 程序运行过程中的一些信息[变量、函数、类与对象等信息]



1. *application* 指的就是当你调用`app = Flask(__name__)`创建的这个对象`app`；
2. *request* 指的是每次`http`请求发生时，`WSGI server`(比如gunicorn)调用`Flask.__call__()`之后，在`Flask`对象内部创建的`Request`对象；
3. *application* 表示用于响应WSGI请求的应用本身，*request* 表示每次http请求；
4. *application*的生命周期大于*request*，一个*application*存活期间，可能发生多次http请求，所以，也就会有多个*request*



- 请求上下文对象

  - request

    ~~~python
    Flask的请求上下文，包含请求变量如:method、args、form、values、endpoint、headers、remote_addr都是比较常用的。
        
      例如 ：　request.args.get ('user' )   获取get请求参数
    ~~~

  - session

    ~~~
    Flask的请求上下文，用于存放用户的会话信息。
    ~~~

    

- 应用上下文对象

  - current_app

    ~~~python
    Flask的应用上下文，返回当前app的方法和属性，可以勉强理解为类全局变量。
    ~~~

  - g

    ~~~
    作为Flask 程序全局中的一个临时变量
    不同的请求有不同的全局变量g
简单来说这个临时变量的生命周期就是一次请求，。
    只在当前请求中共享变量
    ~~~
    
    

### 两者区别：

---

- 请求上下文：保存了客户端和服务器交互的数据
- 应用上下文：flask 应用程序运行过程中，保存的一些配置信息，比如程序名、数据库连接、应用信息等



## 请求钩子                                                                                                                                                                                               

#### flask的四种请求钩子（又称网络拦截器）

- before_first_request
  - 在处理第一个请求之前执行（项目初始化的钩子）
  - 应用场景：开启数据库链接，等等
- before_request
  - 在每次请求前执行
  - 如果在某修饰函数中返回了一个响应，视图函数将不再被调用
  - 应用场景：　做jwt 或者auth 权限认证，　如果不通过则返回一个响应对象，这样下面的视图函数就不走了。
- after_request
  - 必须接收一个response的参数，是请求执行的视图函数的返回对象
  - 如果没有抛出错误，在每次请求后执行
  - 接受一个参数： 将视图函数的作出的响应对象传入
  - 在此函数中可以对响对象中的值在返回之前做最后一部修改处理
  - 需要将参数中的响应子啊此参数中进行返回
- teardown_request
  - 严格来说，没有固定请求的位置，只有请求上下文被pop出栈的时候就会出发这个，所以即使之前有跑出错误都会执行，通俗一点就是当
  - 在视图内部报错之后执行
  - 接受一个参数： 错误信息，如果有相关错误抛出
  - 需要设置flask的配置DEBUG=False，teardown_request才会接受到异常对象。

可以通过request 方法，进行对请求的url及参数或者文件的提取，再进行逻辑判断，从而决定钩子的流程控制及返回值



**after_request**

###### 必须接收一个response的参数，是请求执行的视图函数的返回对象

~~~python
## 请求对应的视图函数执行后＝要执行的钩子函数，在返回客户端之前
@app.after_request
def after_request(responce):
    print('－－－请求执行后需要执行的钩子函数－－－')
    print('－－－主要作用就是对视图函数返回的值到客户端之前进行再此的修饰－－－')
    print(responce.data)
    return responce

#路由
@app.route("/")
def user():
    # 页面跳转响应
    print('----视图函数-----')
    return 'ok'

~~~



**teardown_request**

当视图中报错时候就会触发teardown请求钩子，必须要一个参数接收异常信息

~~~python
## 在视图内，抛出异常就会执行
@app.teardown_request
def teardown_request(exc):
    print('exc %s' % exsc )
~~~



## 异常捕获

主动抛出HTTP异常

---

- abort方法
  - 抛出一个给定状态码的HTTPException或者指定响应，列如想要用一个页面未找到异常来终止请求，你可以调用abort(404)
- 参数：
  - code -HTTP 的错误状态码

~~~python
# abort(404)
abort(500)
~~~

> 抛出状态码的话，只能抛出HTTP协议的错误状态吗



## 捕获错误

- errorhandler 装饰器
  
- 注册一个错误处理程序，当检测到程序抛出指定错误状态吗的时候，就会调用该装饰器所装饰的方法
  
- 参数

  - code_or_exception-HTTP 的错误状态吗或指定异常

- 例如，统一处理“页面找不到”，状态码为500 ，给用户友好的提示

  ~~~python
  @app.errorhandler(404)
  def error_404(error):
      print(error)
      return "<img src=https://raw.githubusercontent.com/chenluzhong150394/img/master/1.png >"
  ~~~

  ![实例](https://raw.githubusercontent.com/chenluzhong150394/img/master/实例1.png)

  

- 捕获指定异常类型

  ~~~python
  @app.errorhandler(ZeroDivisionError)
  def zero_division_error(e):
      return '除数不能为0'
  ~~~

  实例

  ~~~python
  from flask import Flask
  from settings.dev import Config
  # 创建flask应用
  app = Flask(__name__)
  
  """加载配置"""
  app.config.from_object(Config)
  
  """
  flask中内置了app.errorhander提供给我们捕获异常，实现一些在业务发生错误时的自定义处理。
  1. 通过http状态码捕获异常信息
  2. 通过异常类进行异常捕获
  """
  
  """1. 捕获http异常[在装饰器中写上要捕获的异常状态码也可以是异常类]"""
  @app.errorhandler(404)
  def error_404(e):
      return "<h1>您访问的页面失联了！</h1>"
  
  
  """2. 捕获系统异常或者自定义异常"""
  class APIError(Exception):
      pass
  
  @app.route("/")
  def index():
      raise APIError("api接口调用参数有误！")
      return "个人中心，视图执行了！！"
  
  @app.errorhandler(APIError)
  def error_apierror(e):
      return "错误: %s" % e
  
  if __name__ == '__main__':
      app.run(host="localhost",port=8080)
  ~~~

  











## Flask-Script扩展

#### 安装命令：

~~~
pip install flask-script
~~~

集成 Flask-Script到flask应用中，创建一个主应用程序，一般我们叫`manage.py`

#### 配置脚手架使其能通过终端运行项目

~~~python
### 第一步 ，导包
from flask_script import Manager

### 第二步  初始化manger对象，传入app应用进行绑定
manage = Manager(app)

### 第三步，就可以使用manage启动运行项目
if __name__ == '__main__':
    manage.run()

### 使用终端运行, (main.py  为项目文件)
>> python main.py runserver 


### 通过  -？  来获取执行函数的参数
>> python main.py runserver -? 

# 端口和域名不写，默认为127.0.0.1:5000
python manage.py runserver

# 通过-h设置启动域名，-p设置启动端口
python manage.py runserver -h127.0.0.1 -p8080
~~~



#### Flask-Script 可以直接为当前脚本添加新的命令

~~~python
#第一步，首先引入Command基类
from flask_script import Manager,Command

# 第二步 , 自定义命令类，继承Command基类，并将要执行的逻辑放到run方法里面
class  Hello(Command):
    """run方法里面存放着要执行的逻辑"""
    def run(self):
        print('123')
# 第三步，注册自定义命令类并加上别名

manage.add_command('hello', Hello() )
~~~

> 注意，如果有自定义的其他参数传入，需要使用init构造函数导入





# Jinja2模板引擎



flask中内置的模板语言，设计思想来源与django中的模板引擎,flask 内置的render_template 函数封装了这个模板引擎

要想在flask中使用模板引擎，需要做以下设置

~~~python
#首先在创建flask 应用的时候加上  template_folder 参数，指定模板的根目录
app = Flask(__name__,template_folder = 'templates')
## 默认是在项目的根目录下的

## 在视图函数中设置渲染模板设置模板数据
from flask import render_template 

@app.route('/index')
def inde():
    return render_template('index.html',title='我的flask 项目')
~~~

在视图函数中往janja2 模板传入变量

~~~python
### 视图函数
@app.route('/index')
def inde():
    sts = '这也是一个变量'
    return render_template('index.html',title='我的flask 项目',sts)    
## title就是一个变量,  sts 也是 ，这是两种方式，前者是传入已经定义好的变量名，后者是直接变量名加上赋值操作一起做， 


### 在模板中使用变量
## 使用两个花括号来表示变量名  ，，  这种语法叫做** 变量代码块
{{}}      {{ title }}
<head>
    <meta charset="UTF-8">
    <title>{{ title }}</title>
</head>
<body>
~~~



- Jinja2 模板中的变量代码块可以是任何python类型后者对象，只要它能够被python的_\_str\__魔术方法 或者str() 方法转换成字符串就可以，通俗来说只要能被json的对象都可以。



在模板中怎样注释变量

```python
{# {{ name }} #}
```



#### jinja2模板内置的变量和函数

---

> 就是说你可以在模板中直接访问flask内置的函数和对象

- Config

  **你可以直接在模板中访问flask中的config对象**

  ```html
  <h5>{{config.DEBUG}}</h5>
  ```

- request

   **注意：  是当前请求的request对象**

  ~~~html
  <h5>{{request.url}}</h5>
  http://127.0.0.1:5000/index
  ~~~

- session

  **flask中的session对象**

  ~~~html
  {{ session.new}}
  False
  ~~~

- g 变量

  **在视图函数中设置的g变量的name属性的值，然后在模板中可以取出**

  **由于g变量的特性，所以它也只能取到本次请求所携带的g变量的值**

  ~~~
  {{ g.name }}
  ~~~

- url_for()

  **url_for 会根据传入的路由器函数名，返回改路由对应的URL，在模板中始终使用url_for() 就可以安全的修改路由绑定的URL，则不必担心模板中渲染出错的链接：**

  ~~~python
  ## 显示 flask中方法函数对应的路由url地址
  {{url_for('home')}}
  >>  /
  
  
  ## 当有路由函数需要传入参数时，这是我们也需要传入参数就可以将完整url拼接出来
  {{ url_for('user', userid=1)}}
  >>   /user/1
  ~~~



#### 流程控制

---

**主要包含两个，（与django中的基本保持一致）**

~~~html
 - if /else /endif
- for /endfor 
~~~




#### 过滤器

---

常用的过滤器

| 过滤器名   | 说明                                       |
| ---------- | ------------------------------------------ |
| safe       | 渲染时不转义                               |
| capitalize | 把值的首字母转换成大写，其他字母转换成小写 |
| lower      | 把值转换成小写形式                         |
| upper      | 把值转换成大写形式                         |
| title      | 把值中每个单词的首字母都转换成大写         |
| trim       | 把值的首尾空格都去掉                       |
| striptags  | 渲染前把值中的所有的HTML标签都删掉         |

~~~html5
## safe 过滤器  ,因为默认的安全机制会对html代码字符串进行转码。不让其正常进行渲染。

{{ index |  safe }}
~~~



#### 在jinja2 中， 过滤器是可以直接链式调用的

~~~python
{{"hello world " | reverse | uppper  }} 
~~~

#### 链式调用



















安装









## github 可以当做静态资源仓库，调用的url为

~~~python

https://raw.githubusercontent.com/chenluzhong150394/img/master/1.png


### 这是仓库的url，（可以查看内容的）
https://raw.githubusercontent.com/chenluzhong150394
    
    
    
    https://raw.githubusercontent.com/chenluzhong150394/img/master/11.png

~~~





![](https://u8b3.cn/uSOl2)









### lsof -i:8080 linux 查看端口













title: celery中停止执行task
date: 2019-07-06 17:26:24
desc: celery中停止执行task
tags: [celery, python] 
categories: python
---

<!-- more -->

## 原因
因为最近项目需求中需要提供对异步执行任务终止的功能，所以在寻找停止celery task任务的方法。这种需求以前没有碰到过，所以，只能求助于百度和google，但是找遍了资料，都没找到相关的能停止celery task任务的方法(网上找到的一个方法实测不能用，可能是celery版本的原因，我的项目目前使用的是celery 4.0.2)

## 解决过程
由于网上找不到解决办法，于是只能自己想办法了。
想到celery 管理工具flower里面好像有停止celery task的功能，于是去找flower的源码，找到接口的源码如下:

```python
logger.info("Revoking task '%s'", taskid)
terminate = self.get_argument('terminate', default=False, type=bool)
self.capp.control.revoke(taskid, terminate=terminate)
self.write(dict(message="Revoked '%s'" % taskid))
```

核心代码是`self.capp.control.revoke` 想到去celery里面找寻`revoke`函数，发现有两处比较可疑，第一个是`celery.worker.control.revoke`，第二个是`celery.app.control.Control.revoke`，直觉来看，应该是第二个方法，但是第二个方法是在一个类里面的，要调用这个方法首先需要获取到celery app的实例，后来去celery 配置里面找，发现在__init__.py文件里面有`__all__ = ['celery_app']`这么一句，于是找到突破点了，引用这个包就能获取到celery_app了。

```python
from test.ceyery_proj import celery_app
celery_app.control.revoke(task_id, terminate=True)
```

通过这个方法就能终止正在执行的task，至于task_id在执行任务的时候返回了，我将这个id存储在数据库中，这样就可以被拿来控制task的执行了。

写这篇文档的目的主要是帮助小伙伴们不要再踩这个坑了，也为celery提供一点文档补充吧。



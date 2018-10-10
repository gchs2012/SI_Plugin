# SI_Plugin

## 一、source insight 3.5 使用方法如下
```
添加步骤：
1、将 Quicker3.em 文件放到 source insight 的 base 工程中，默认路径为：C:\Users\root\Documents\Source Insight\Projects\Base
2、在 Options-》Key Assignments -》Command: Macro: AutoExpand 添加快捷键: ctrl + enter；
3、保存此设置;
4、如输入：co后，按 ctrl + enter 就能显示信息。
```

常用命令：
1、config 或 co 			配置语言环境，0 - 中文，1 - 英文
2、file 或 fi				生成文件头说明
3、hd						生成C语言头文件
4、hdn						生成不要文件名的新头文件
5、func 或 fu				生成函数头
6、/*						生成行注释
7、｛						生成一对括号 { }
8、do						生成do - while循环
9、while 或 wh				生成while循环
10、for 或 fo				生成for循环
11、if						生成if语句
12、else 或 el				生成else分支
13、ef						生成else if分支
14、ife						生成if - else
15、ifs						生成if - else if - else
16、switch 或 sw			生成switch - case
17、#ifd 或 #ifdef			生成#ifdef - #endif
18、#ifn 或 #ifndef			生成#ifndef - #endif
19、#if 					生成#if - #endif
20、case 或 ca 				生成case
21、struct 或 st			生成结构体
22、enum 或 en 				生成枚举结构
23、hi						生成修改历史记录
24、abg						生成添加代码记录
25、dbg						生成删除代码记录
26、mbg						生成修改代码记录
27、tab						将tab键转换为空格
28、ab						生成添加记录开始
29、ae						生成添加记录结束
30、db						生成删除记录开始
31、de						生成删除记录结束
32、mb						生成修改记录开始
33、me						生成修改记录结束
35、pn						添加问题单号，如果输入‘#’，则单号为空
36、name					修改用户名


二、source insight 4.0 使用方法如下
添加步骤：
1、将 Quicker4.em 文件放到 source insight 的 base 工程中，默认路径为：C:\Users\root\Documents\Source Insight 4.0\Projects\Base
2、在 Options-》Key Assignments -》Command: Macro: AutoExpand 添加快捷键: ctrl + enter
3、保存此设置
4、如输入：config后，按 ctrl + enter 就能显示信息

常用命令：
1、config  			        配置语言环境，0 - 中文，1 - 英文，如果输入‘#’，则语言为中文
2、name					    修改用户名，如果输入‘#’，则用户名为Mr.Zhang
3、company                  修改公司名称，如果输入‘#’，则公司名称为xxx Co.xxx, Ltd.
4、pn						添加问题单号，如果输入‘#’，则单号为空
5、file      				生成文件头说明
6、func		       		    生成函数头
7、abg						生成添加代码记录
8、dbg						生成删除代码记录
9、mbg						生成修改代码记录


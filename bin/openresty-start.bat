@echo off

rem 启动标志 flag=0 表示之前已经启动   flag=1 表示现在立即启动
set flag=0

rem 设置 openresty/nginx的安装目录
set installPath=C:/home/dev/openresty-1.21.4.1

rem 设置 Nginx 项目的工作目录
set projectPath=C:/home/project/lua/lua-demo

rem 设置 项目的配置文件
set PROJECT_CONF=nginx.conf

echo installPath: %installPath%
echo project prefix path: %projectPath%
echo config file: %projectPath%/conf/%PROJECT_CONF%
echo openresty starting.....

rem 查找openresty/nginx进程信息，然后设置flag标志位
tasklist | find /i "nginx.exe" > nul
if %errorlevel% == 0 (
echo "openresty/nginx already running ! "
rem exit /b
) else set flag=1

rem 如果需要，则启动 openresty/nginx
rem -p指定前缀路径，-c指定nginx配置文件

if %flag% == 1 (
start %installPath%/nginx.exe -p "%projectPath%" -c "%projectPath%/conf/%PROJECT_CONF%"
ping localhost -n 2 > nul
)

rem 输出openresty/nginx的进程信息
tasklist /fi "imagename eq nginx.exe"
tasklist | find /i "nginx.exe" > nul
if %errorlevel% == 0 (
echo "openresty/nginx  starting  succeced!"
)

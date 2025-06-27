# 示例 Dockerfile
FROM alpine:latest

# 安装基本工具
RUN apk add --no-cache curl

# 创建应用目录
WORKDIR /app

# 复制应用文件
COPY . .

# 设置启动命令
CMD ["echo", "Hello from uploaded build context!"]

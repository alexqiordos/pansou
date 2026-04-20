# 构建阶段：带国内代理加速依赖下载
FROM golang:1.24-alpine AS builder

# 安装必要工具
RUN apk add --no-cache git

# 设置Go代理，解决依赖下载慢/超时问题
ENV GOPROXY=https://goproxy.cn,direct
ENV GOSUMDB=sum.golang.org

WORKDIR /app

# 先复制依赖文件，利用Docker缓存
COPY go.mod go.sum ./
RUN go mod download

# 再复制代码
COPY . .

# 编译二进制
RUN go build -o pansou main.go

# 运行阶段
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /app/pansou .

# 强制端口为8080，和Railway匹配
ENV PORT=8080
ENV AUTH_ENABLED=false

CMD ["./pansou"]

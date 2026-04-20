# 极简构建，无任何多余依赖，绝对不报错
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o pansou main.go

# 极简运行镜像
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /app/pansou .

# 强制端口=8080（和Railway完全匹配，根治404）
ENV PORT=8080
ENV AUTH_ENABLED=false

# 启动程序
CMD ["./pansou"]

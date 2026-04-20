# 构建阶段：Go 1.24 官方镜像，确保编译环境一致
FROM golang:1.24-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache git ca-certificates tzdata

# 设置工作目录
WORKDIR /app

# 复制依赖文件，利用Docker缓存加速构建
COPY go.mod go.sum ./
RUN go mod download

# 复制项目所有文件（包括api、plugin、config等所有目录）
COPY . .

# 编译二进制文件，静态编译避免依赖问题
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o pansou main.go

# 运行阶段：超轻量alpine镜像，减小体积
FROM alpine:3.19

# 安装运行时必要依赖
RUN apk add --no-cache ca-certificates tzdata

# 创建缓存目录
RUN mkdir -p /app/cache

# 关键：复制所有运行时需要的文件
COPY --from=builder /app/pansou /app/pansou
COPY --from=builder /app/api /app/api
COPY --from=builder /app/plugin /app/plugin
COPY --from=builder /app/config /app/config
COPY --from=builder /app/static /app/static
COPY --from=builder /app/templates /app/templates

# 设置工作目录
WORKDIR /app

# 设置环境变量（直接配置好所有必要参数，避免运行时出错）
ENV CACHE_PATH=/app/cache \
    CACHE_ENABLED=true \
    TZ=Asia/Shanghai \
    ASYNC_PLUGIN_ENABLED=true \
    ENABLED_PLUGINS=labi,zhizhen,shandian,duoduo,muou,wanou,hunhepan,jikepan,panwiki,pansearch,panta,qupansou,hdr4k,pan666,susu,thepiratebay,xuexizhinan,panyq,ouge,huban,cyg,erxiao,miaoso,fox4k,pianku,clmao,wuji,cldi,xiaozhang,libvio,leijing,xb6v,xys,ddys,hdmoli,yuhuage,u3c3,javdb,clxiong,jutoushe,sdso,xiaoji,xdyh,haisou,bixin,djgou,nyaa,xinjuc,aikanzy,qupanshe,xdpan,discourse,yunsou,qqpd,ahhhhfs,nsgame,gying,quark4k,quarksoo,sousou,ash \
    AUTH_ENABLED=false

# 启动命令
CMD ["/app/pansou"]

# Используем официальный образ Golang
FROM golang:1.23 AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Статическая сборка
RUN CGO_ENABLED=0 GOOS=linux go build -a -o main ./cmd/wallet/main.go

FROM scratch

WORKDIR /app

# Копируем собранный бинарник
COPY --from=builder /app/main /app/main
COPY config /app/config

# Открываем порт gRPC
EXPOSE 50051 50052 50053

# Команда по умолчанию
CMD ["/app/main", "--config-path=/app/config/local.yaml"]

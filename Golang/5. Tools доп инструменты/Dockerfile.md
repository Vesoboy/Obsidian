- Основы:
    
    dockerfile
    
    FROM golang:1.20-alpine
	WORKDIR /app
	COPY . .
	RUN go build -o app .
	CMD ["./app"]>)
    
- Команды:
    - `FROM` — базовый образ.
    - `WORKDIR` — рабочая директория.
    - `COPY` — копирование файлов.
    - `RUN` — выполнение команд.
    - `CMD` — запуск приложения.

#### 2. **Использование docker-compose**

- Пример `docker-compose.yml` для приложения Go и PostgreSQL:

	version: '3.8' 
	services: 
		app: 
			build: . 
			ports: 
				- "8080:8080" 
			depends_on: - db 
		db: 
			image: postgres:15 
			environment: 
				POSTGRES_USER: user 
				POSTGRES_PASSWORD: password 
				POSTGRES_DB: mydb 
			ports: 
				- "5432:5432"
    

#### 3. **Оптимизация образов для Go**

- Использование multi-stage builds:
    
    dockerfile
    
    FROM golang:1.20-alpine AS builder
	WORKDIR /app
	COPY . .
	RUN go build -o app .
	
	FROM alpine:latest
	WORKDIR /root/
	COPY --from=builder /app/app .
	CMD ["./app"]>)
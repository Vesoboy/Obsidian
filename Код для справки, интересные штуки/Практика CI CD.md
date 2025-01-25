# 1. Предварительная подготовка

1. **Создай репозиторий** на GitHub для своего проекта.
2. Убедись, что у тебя есть файл `go.mod` (для управления зависимостями).
3. Создай минимальную структуру проекта, например:
go
	my-go-app/ 
	├── main.go // основной код приложения 
	├── go.mod // файл модулей Go 
	└── .github/ 
		└── workflows/ 
			└── ci-cd.yml // файл конфигурации GitHub Actions

# 2. Пример файла GitHub Actions: 
`.github/workflows/ci-cd.yml`

yaml
	name: Go CI/CD Pipeline
	on:
	  push:
	    branches:
	      - main  # Слушаем изменения в ветке main
	  pull_request:
	    branches:
	      - main
	jobs:
	  build-and-test:
	    runs-on: ubuntu-latest
	    steps:
			# Шаг 1: Клонируем репозиторий
			- name: Checkout code
		    uses: actions/checkout@v3
		    ``
		    # Шаг 2: Устанавливаем Go
		      - name: Set up Go
	        uses: actions/setup-go@v4
			with:
		         go-version: 1.20  # Укажи свою версию Go
		         ``
		    # Шаг 3: Устанавливаем зависимости
			    - name: Install dependencies
			    run: go mod tidy
			    ``
		    # Шаг 4: Сборка приложения
			    - name: Build the application
		        run: go build -v ./...
		        ``
		    # Шаг 5: Запуск тестов
			    - name: Run tests
		        run: go test -v ./...
		        ``
	  deploy:
	    needs: build-and-test
	    runs-on: ubuntu-latest
	    if: github.ref == 'refs/heads/main'  # Деплой только из ветки main
	    ``
	    steps:
		    # Шаг 1: Клонируем репозиторий
		      - name: Checkout code
		      uses: actions/checkout@v3
		      ``
		    # Шаг 2: Логинимся в Docker Hub
		      - name: Log in to Docker Hub
		      uses: docker/login-action@v2
		      with:
		          username: ${{ secrets.DOCKER_USERNAME }}
		          password: ${{ secrets.DOCKER_PASSWORD }}
		          ``
		    # Шаг 3: Собираем Docker-образ
		      - name: Build and push Docker image
		      run: |
		          docker build -t my-docker-user/my-go-app:latest .
		          docker push my-docker-user/my-go-app:latest

# 3. Пошаговое объяснение

#### **Секция `on`**

- **`push`**: Запускает пайплайн при каждом пуше в ветку `main`.
- **`pull_request`**: Запускает пайплайн при создании PR в ветку `main`.

#### **Job 1: build-and-test**

1. **`runs-on: ubuntu-latest`** — Виртуальная машина с Ubuntu.
2. **Установка Go**: Используем action `setup-go`, чтобы установить нужную версию.
3. **Сборка и тесты**:
    - `go build` собирает приложение.
    - `go test` запускает тесты.

#### **Job 2: deploy**

1. Выполняется только если первый job (build-and-test) успешно завершён.
2. Проверяет, что код пушится из ветки `main`.
3. **Docker-деплой**:
    - Логинится в Docker Hub через секреты (`DOCKER_USERNAME` и `DOCKER_PASSWORD`).
    - Собирает и пушит Docker-образ с приложением.

# 4. Как настроить секреты в GitHub?

1. Перейди в настройки своего репозитория:  
    `Settings → Secrets and variables → Actions → New repository secret`.
2. Создай два секрета:
    - `DOCKER_USERNAME`: Твой Docker Hub username.
    - `DOCKER_PASSWORD`: Пароль от Docker Hub.

# 5. Dockerfile (пример)

Если ты используешь Docker, добавь файл `Dockerfile` в корень проекта:

dockerfile

	#Используем базовый образ с Go
	FROM golang:1.20
	
	#Устанавливаем рабочую директорию
	WORKDIR /app
	
	#Копируем все файлы в контейнер
	COPY . .
	
	#Скачиваем зависимости
	RUN go mod tidy
	
	#Собираем приложение
	RUN go build -o my-go-app .
	
	#Запускаем приложение
	CMD ["./my-go-app"]

# 6. Проверка

- После пуша в ветку `main` пайплайн автоматически запустится.
- Если всё настроено верно, результатом будет успешный билд и публикация Docker-образа на Docker Hub.


# [[CI CD]]
# Как работает пайплайн на практике?

Допустим, ты работаешь над Go-приложением. Вот как может выглядеть пайплайн:

1. **Кто-то делает `git push` в ветку `main`.**
2. Пайплайн начинает работать:
    - Забирает код из репозитория.
    - Устанавливает Go.
    - Устанавливает зависимости через `go mod tidy`.
    - Проверяет код (`golangci-lint`).
    - Запускает тесты (`go test ./...`).
3. Если все шаги успешны, собирается Docker-образ.
4. Образ деплоится в Kubernetes или публикуется в Docker Hub.

# Пример пайплайна для CI/CD

На платформе [[GitLab]] **CI/CD** файл конфигурации `.gitlab-ci.yml` может выглядеть так:

yaml
	stages:
		- lint
		- test
		- build
		- deploy
	``
	lint:
		  stage: lint
		  script:
		    - go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
		    - golangci-lint run
		  only:
		    - main
	``
	test:
		stage: test
		script:
			- go test -v ./...
		only:
			- main
	``
	build:
		  stage: build
		  script:
			- go build -o app .
		  artifacts:
			paths:
				- app
		  only:
			- main
	``
	deploy:
		  stage: deploy
		  script:
		    - echo "Deploying to production..."
		    - scp app user@yourserver:/path/to/app
		  only:
		    - main

# Инструменты для работы с пайплайнами

1. [[GitHub]]**Actions** — мощный инструмент для CI/CD на GitHub.
2. [[GitLab]] **CI/CD** — встроенная система CI/CD в GitLab.
3. **Jenkins** — гибкий, но требует больше настройки.
4. **CircleCI** — удобен для контейнеризированных приложений.
5. **Travis CI** — простой в использовании, но меньше функций в бесплатной версии.
6. **ArgoCD** — для управления Kubernetes-деплоем.

# [[Pipeline]]
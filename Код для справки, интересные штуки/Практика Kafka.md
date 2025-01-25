# Установка библиотеки

Сначала установим библиотеку:

bash
	`go get github.com/confluentinc/confluent-kafka-go/kafka`

Также убедитесь, что у вас установлен и запущен Kafka-сервер. Например, можно использовать [Docker Compose](https://kafka.apache.org/quickstart) для поднятия Kafka локально.

# Пример: Продюсер и Потребитель

## 1. Создание Продюсера (Producer)

Продюсер отправляет сообщения в Kafka.

go

`package main  
	import ( 	
		"fmt" 	
		"github.com/confluentinc/confluent-kafka-go/kafka" 
	) 
	func main() { 	
		// Создаем конфигурацию продюсера 	
		producer, err := kafka.NewProducer(&kafka.ConfigMap{"bootstrap.servers": "localhost:9092"}) 	
		if err != nil { 		
			panic(err) 	
		} 	
		defer producer.Close()  	
		// Топик для сообщений 	
		topic := "example-topic"  	
		// Отправка сообщения 	
		message := "Привет из Go!" 	
		err = producer.Produce(&kafka.Message{ 		
			TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny}, 		
			Value:          []byte(message), 	
		}, nil)  	
		if err != nil { 		
		fmt.Println("Ошибка отправки:", err) 	
		} else { 		
		fmt.Println("Сообщение отправлено:", message) 	
		}  	
		// Ожидаем завершения отправки 	
		producer.Flush(1000)
	 }`

## 2. Создание Потребителя (Consumer)

Потребитель читает сообщения из Kafka.

go

`package main  
	import ( 	
		"fmt" 	
		"github.com/confluentinc/confluent-kafka-go/kafka" 
	)  
	func main() { 	
		// Создаем конфигурацию потребителя 	
		consumer, err := kafka.NewConsumer(&kafka.ConfigMap{ 		
			"bootstrap.servers": "localhost:9092", 		
			"group.id":          "example-group", 		
			"auto.offset.reset": "earliest", // Чтение с самого начала 	
			}) 	
		if err != nil { 		
			panic(err) 	
		} 	
		defer consumer.Close()  	
		// Подписываемся на топик 	
		topic := "example-topic" 	
		err = consumer.SubscribeTopics([]string{topic}, nil) 	
		if err != nil { 		
			panic(err) 	
		}  	
		fmt.Println("Ожидание сообщений...")  	
		// Читаем сообщения в бесконечном цикле 
		for { 		
			msg, err := consumer.ReadMessage(-1) 		
			if err != nil { 			
				fmt.Println("Ошибка чтения сообщения:", err) 			
				continue 		
			} 		
			fmt.Printf("Получено сообщение: %s\n", string(msg.Value)) 	
		} 
	}`

# Как это работает?

1. **Producer**:
    - Подключается к Kafka через `bootstrap.servers` (например, `localhost:9092`).
    - Отправляет сообщения в указанный **топик**.
    - Использует функцию `Produce` для отправки данных.
2. **Consumer**:
    - Подключается к Kafka с помощью конфигурации.
    - Подписывается на один или несколько **топиков**.
    - Читает сообщения через `ReadMessage`.

---

# Запуск

1. Запустите Kafka на вашем локальном сервере.
2. Сначала запустите **Consumer**, чтобы он ждал сообщений.
3. Затем запустите **Producer**, чтобы отправить сообщение.
4. Consumer выведет полученное сообщение в консоль.

# Что дальше?

- **Настройка Kafka:** Можно добавить параметры аутентификации (SASL, SSL).
- **Масштабируемость:** Запустите несколько продюсеров и потребителей.
- **Партиционирование:** Разделите топики на несколько партиций для параллельной обработки.
- **Kafka Streams:** Для обработки потоков данных в реальном времени.

# [[Kafka]]
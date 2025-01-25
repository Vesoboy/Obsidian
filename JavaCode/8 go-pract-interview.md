### 1

Посчитайте сумму n-го ряда пирамиды нечетных чисел (начало с 1)
      1
     3 5
    7 9 11
  13 15 17 19
 21 23 25 27 29

Ответ:

```go
func Sum(pir [][]int, n int) int {
	sum := 0
	for i := 0; i <= n; i++ {
		sum += pir[n][i]
	}

	return sum
}

fmt.Println(Sum([][]int{{1}, {3, 5}, {7, 9, 11}}, 2))
```

---

### 2

Реализуйте алгоритм, который принимает массив и перемещает все нули в конец, сохраняя порядок остальных элементов.
[1, 0, 1, 2, 0, 1, 3]

Ответ:

```go
// вариант 1
func moveZeros(arr []int) []int {
    // Создаем новый массив для хранения результата
    result := make([]int, 0, len(arr))
    zeroCount := 0

    // Проходим по исходному массиву
    for _, num := range arr {
        if num != 0 {
            // Добавляем ненулевые элементы в результат
            result = append(result, num)
        } else {
            // Увеличиваем счетчик нулей
            zeroCount++
        }
    }

    // Добавляем нули в конец результата
    for i := 0; i < zeroCount; i++ {
        result = append(result, 0)
    }

    return result
}
arr := []int{1, 0, 1, 2, 0, 1, 3}
result := moveZeros(arr)
fmt.Println(result) // Вывод: [1 1 2 1 3 0 0]

// вариант 2

func moveZeros(arr []int) {
    // Индекс для ненулевых элементов
    lastNonZeroIndex := 0

    // Проходим по массиву
    for i := 0; i < len(arr); i++ {
        if arr[i] != 0 {
            // Меняем местами ненулевой элемент с элементом на позиции lastNonZeroIndex
            arr[lastNonZeroIndex], arr[i] = arr[i], arr[lastNonZeroIndex]
            lastNonZeroIndex++
        }
    }
}
arr := []int{1, 0, 1, 2, 0, 1, 3}
moveZeros(arr)
fmt.Println(arr) // Вывод: [1 1 2 1 3 0 0]
```

---

### 3

Вывести длину строки в символах и количество байт
"Что то world %$@@&"

Ответ

```go
// Длина строки в символах
lengthInRunes := utf8.RuneCountInString(str)

// Количество байт
byteCount := len(str)

fmt.Printf("Длина строки в символах: %dn", lengthInRunes)
fmt.Printf("Количество байт: %dn", byteCount)
```

---

### 4

Заменить символ в строке
"Hello, world!"
Все l на n

Ответ

```go
str := "Hello, world!"
 // Заменяем все 'l' на 'n'
 newStr := strings.ReplaceAll(str, "l", "n")

 fmt.Println(newStr) // Вывод: "Henno, worrd!"
```

---

### 5

Слить N каналов в один

```go
func merge(chs ...chan int) chan int {
}

func main() {
	ch1 := startProducerA()
	ch2 := startProducerB()

	for el := range merge(ch1, ch2) {
		println(el)
	}
}
```
Ответ

```go
func merge(chs ...chan int) chan int {
	newCh := make(chan int)
	wg := sync.WaitGroup{}

	for _, ch := range chs {
		wg.Add(1)
		go func(ch chan int) {
			for val := range ch {
				newCh <- val
			}
			wg.Done()
		}(ch)
	}

	go func() {
		wg.Wait()
		close(newCh)
	}()

	return newCh
}
```

---

### 6

Понять логику и ревлизовать функцию
```
[1,2,3,4,5] -> [1,3,5]
[2,2,2] -> []
[1,2,2] -> [1]
```

Ответ

```go
func filter(a []int) []int {
	var n int

	for i := 0; i < len(a); i++ {
		if a[i]%2 != 0 {
			a[n] = a[i]
			n++
		}
	}

	return a[:n]
}
```

---

### 7

Предлагаю реализовать вариант rate limiter соответствующего интерфейсу Limiter
Основной концепт заключается в том, что у нас есть некоторая корзина токенов для каждого ключа key, при вызове
метода Allow мы уменьшаем количество токенов на 1.
Если количество токенов стало равным 0, возвращаем false, в остальных случаях нужно вернуть true .
Токены начисляются с некоторой скоростью, скажем n в сек для каждого ключа. Также существует некоторое максимальное
значение токенов, выше которого токены не начисляются.

Пример, максимальное количество токенов для ключа 5, за каждую секунду начисляется 5 токенов, за каждый запрос
списывается 1 токен.
Это значит, что мы можем делать 5 запросов в секунду.

Многопоточку можно подумать
Горутины здесь не потребуются
Мы можем хранить время последнего захода в функцию по ключу и при новом вызове вычислять дельту между текущим
временем и сохраненным. Исходя из этого начислять токены
Единица округления, единица расчета секунды. Если дельта 0сек, то нчиего не начисляем.

```go
type Limiter interface {
	Allow(key string) bool
}
```

Ответ

```go
type Limiter interface {
	Allow(key string) bool
}

type tokenParams struct { // Про многопоточку: хочется добавить мьютекс😁
	max        int32
	speed      int32
	count      int32
	accessTime time.Time
}

type Baskets struct {
	basket map[string]tokenParams
}

func NewBaskets() Baskets {
	baskets := Baskets{
		basket: make(map[string]tokenParams),
	}

	return baskets
}

func (b Baskets) Allow(key string) bool {
	if _, exists := b.basket[key]; !exists {
		fmt.Printf("key %s not found", key)
		return false
	}

	creditedTokens := int32(0)
	now := time.Now()

	if !b.basket[key].accessTime.IsZero() {
		delta := now.Sub(b.basket[key].accessTime).Seconds()
		creditedTokens = int32(math.Floor(delta)) * b.basket[key].speed // за < 1 секунды начисляется 0

		if creditedTokens > b.basket[key].max {
			creditedTokens = b.basket[key].max
		}
	} else {
		creditedTokens = b.basket[key].max // первый раз начисляем максимум
	}

	newCount := b.basket[key].count - 1 + creditedTokens
	if newCount < 0 { // не снижаем токены, если токены потрачены
		return false
	}

	b.basket[key] = tokenParams{
		max:        b.basket[key].max,
		speed:      b.basket[key].speed,
		count:      newCount,
		accessTime: now,
	}

	return true
}

basket := NewBaskets()
basket.basket["key"] = tokenParams{
    max:        5,
    speed:      1,
    count:      5,
    accessTime: time.Time{},
}
fmt.Println(basket.Allow("key"))
fmt.Println(basket.Allow("key"))
fmt.Println(basket.Allow("key"))
fmt.Println(basket.Allow("key"))
fmt.Println(basket.Allow("key"))
```

---

### 8

Произвести обработку ссылок, отправив GET запросы на URL и выводить в консоль 200 статус ответа или иной
Распараллелить обработку ссылок
Реализовать остановку обработки после получения извне сигнала о прекращении работы
```go
func main() {
	var urls = []string{
		"http://google.com",
		"https://ya.ru",
		"http://ya.ru",
	}
}

func getExternalSignal() chan struct{} {
	return make(chan struct{})
}
```

Ответ

```go
func main() {
	var urls = []string{
		"http://google.com",
		"https://ya.ru",
		"http://ya.ru",
	}

	externalSignal := getExternalSignal()
	sign := atomic.Int32{}
	go func() {
		<-externalSignal
		sign.Store(1)
	}()
	ch := make(chan string)
	wg := sync.WaitGroup{}

	wg.Add(len(urls))
	for i := 0; i < len(urls); i++ {
		i := i
		go func() {
			if sign.Load() == 1 {
				return
			}

			resp, err := http.Get(urls[i])
			if err != nil {
				slog.Error("err", "http get", err)
			}

			if resp.StatusCode == 200 {
				ch <- fmt.Sprintf("адрес %s - ok", urls[i])
			} else {
				ch <- "not ok"
			}

			wg.Done()
		}()
	}

	go func() {
		wg.Wait()
		close(ch)
	}()

	for msg := range ch {
		fmt.Println(msg)
	}
}

func getExternalSignal() chan struct{} {
	return make(chan struct{})
}
```

---

Дан массив meetings, в котором каждый элемент meeting[i] - это пара двух чисел [startTime, endTime].
Необходимо объединить все накладывающиеся друг на друга встречи и вернуть массив с объединенными встречами, покрывающих те же временные слоты.

Input: [[1,3], [2,6], [8,10], [15,18]]
Output: [[1,6], [8,10], [15,18]]
Explanation: Интервалы [1,3] и [2,6] пересекаются => объединяем в [1,6].

```go
func join(meet [][]int) [][]int{
    intervals := make([][]int, 0)

    for i := 0; i < len(meet) - 1; i++{
        if meet[i][1] > meet[i+1][0]{
            intervals = append(intervals, []int{meet[i][0], meet[i+1][1]})
        } else {
            intervals = append(intervals, meet[i])
        }
    }

    return intervals
}
```

---

### 9

Вывести числа от 1 до 10 функцией с PrintLn и задежкой 1 секунда выводом по 5 чисел в одном потоке

```go
func printNumbers() {
 for i := 1; i <= 10; i++ {
  fmt.Println(i)
  if i%5 == 0 {
   time.Sleep(1 * time.Second) // Задержка в 1 секунду после каждых 5 чисел
  }
 }
}
```

---

### 10

Что выведет код и почему?

```go
func setLinkHome(link *string) {
	*link = "http://home"
}

func main() {
	link := "http://other"

	setLinkHome(&link)

	fmt.Println(link)
}
```

---

### 11

Будет ли напечатан “ok” ?

```go
func main() {
	defer func() {
		recover()
	}()

	panic("test panic")

	fmt.Println("ok")
}
```

---

### 12

Функция должна напечатать:
one
two
three
(в любом порядке и в конце обязательно)
done!

Но это не так, исправь код

```go
func printText(data []string) {
	for _, v := range data {
		go func() {
			fmt.Println(v)
		}()

	}

	fmt.Println("done!")

}

func main() {
	data := []string{"one", "two", "three"}

	printText(data)
}
```

---

### 13

Мы пытаемся подсчитать количество выполненных параллельно операций, что может пойти не так?

```go
var callCounter uint

func main() {
	wg := sync.WaitGroup{}

	wg.Add(10000)
	for i := 0; i < 10000; i++ {
		go func() {
			// Ходим в базу, делаем долгую работу
			time.Sleep(time.Second)
			// Увеличиваем счетчик
			callCounter++
			wg.Done()
		}()
	}

	wg.Wait()

	fmt.Println("Call counter value = ", callCounter)
}
```

---

### 14

Есть функция processDataInternal, которая может выполняться неопределенно долго.
Чтобы контролировать процесс, мы добавили таймаут выполнения ф-ии через context.
Какие недостатки кода ниже?

```go
type Service struct {
}

func (s *Service) processDataInternal(r io.Reader) error {
	return nil
}

func (s *Service) ProcessData(timeoutCtx context.Context, r io.Reader) error {
	errCh := make(chan error)

	go func() {
		errCh <- s.processDataInternal(r)
	}()

	select {
	case err := <-errCh:
		return err
	case <-timeoutCtx.Done():
		return timeoutCtx.Err()
	}
}
```

---

### 15

Опиши, что делает функция isCallAllowed?

```go
var callCount = make(map[uint]uint)

var locker = &sync.Mutex{}

func isCallAllowed(allowedCount uint) bool {
	if allowedCount == 0 {
		return true
	}

	locker.Lock()
	defer locker.Unlock()

	curTimeIndex := uint(time.Now().Unix() / 30)

	prevIndexVal, _ := callCount[curTimeIndex-1]

	if prevIndexVal >= allowedCount {
		return false
	}

	curIndexVal, ok := uint(0), false
	if curIndexVal, ok = callCount[curTimeIndex]; !ok {
		callCount[curTimeIndex] = 1

		return true
	}

	if (curIndexVal + prevIndexVal) >= allowedCount {
		return false
	}

	callCount[curTimeIndex]++

	return true
}

func main() {
	fmt.Printf("%v\n", isCallAllowed(3)) // true
	fmt.Printf("%v\n", isCallAllowed(3)) // true
	fmt.Printf("%v\n", isCallAllowed(3)) // true

	// time.Sleep(time.Second*30)

	fmt.Printf("%v\n", isCallAllowed(3)) // false
	fmt.Printf("%v\n", isCallAllowed(3)) // false

}
```

---

### 16

Просмотреть код, назвать, что выведется в stdout
Найти все проблемы в коде и решить их

```go
package main

import (
	"fmt"
	"time"
)

type Agent struct {
	ID      int
	Enabled bool
}

func (a Agent) Enable() {
	a.Enabled = true
}

type Enabler interface {
	Enable()
}

// 1. Инициализация слайса агентов
// 2. Дополнение слайса сторонними агентами
// 3. Потоковая обработка объектов - активация и отправка на выполнение работы
// 4. Потоковая обработка объектов - сохранение в БД и распечатка резульатов
func main() {
	agents := make([]Agent, 0, 5)
	for i := 0; i < 2; i++ {
		agents = append(agents, Agent{ID: i})
	}

	addThirdPartyAgents(agents)

	pipe := make(chan Enabler)
	go pipeEnableAndSend(pipe, agents)
	go pipeProcess(pipe)
}

func addThirdPartyAgents(agents []Agent) {
	thirdParty := []Agent{
		{ID: 4},
		{ID: 5},
	}
	agents = append(agents, thirdParty...)
}

func pipeEnableAndSend(pipe chan Enabler, agents []Agent) {
	for _, a := range agents {
		a.Enable()
		pipe <- a
	}
}

func pipeProcess(pipe chan Enabler) {
	for {
		select {
		case a := <-pipe:
			dbWrite(a)
		}
	}
}

var dbWrite = func(a any) {
	fmt.Println(a)
	time.Sleep(time.Second * 1)
}
```

---

### 17

```go
package main

import (
    "fmt"
    "sync"
    "time"
)

var cacheStore sync.Map

const timeout = time.Second

// GetData возвращает данные из getter, страхуя кешом
// в случае ошибки. Проблема: getter может отвечать очень долго.
// Задача: в случае ответа дольше timeout отдавать кеш,
// и правильно обработать кейс, когда getter всегда отвечает долго.
func GetData(key string, getter func() (interface{}, error)) (interface{}, error) {
    data, err := getter()
    if err == nil {
        cacheStore.Store(key, data)
        return data, nil
    }

    fmt.Printf("Getter result err: %s", err)
    if data, ok := cacheStore.Load(key); ok {
        return data, nil
    }

    return nil, err
}
```

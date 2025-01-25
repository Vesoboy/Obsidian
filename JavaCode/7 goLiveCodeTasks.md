#### Задание 1
Что выведет код? Исправьте код так, чтобы вывелось "end"

```go
func main() {
	runtime.GOMAXPROCS(1)

	done := make(chan struct{})

	go func() {
		fmt.Println("send command end")
	}()

	<-done
	fmt.Println("end")
}
```

runtime.GOMAXPROCS(1) ограничит количество используемых процессоров до одного. 
В этом случае основная горутина может не успеть получить сигнал от горутины, и программа завершится без вывода.
К тому же мы не посылаем ничего в канал done, поэтому получим deadlock

_Ответ:_

Нужно в сторонней горутине послать структуру в кангал.
Также можно увеличив количество процессоров с помощью runtime.GOMAXPROCS(runtime.NumCPU()) или добавив задержку в горутину
с помощью time.Sleep, чтобы дать основной функции больше времени для ожидания сигнала.

```go
func main() {
	runtime.GOMAXPROCS(runtime.NumCPU()) // Устанавливаем количество процессоров для выполнения

	done := make(chan struct{})

	go func() {
		fmt.Println("send command end")
		time.Sleep(100 * time.Millisecond) // Добавляем задержку
        done <- struct{}{} // Отправляем сигнал о завершении
	}()

	<-done
	fmt.Println("end")
}
```

---

#### Задание 2

Есть код:
```go
func main() {
	var value int
	//var mu sync.Mutex
	//var wg sync.WaitGroup
	for i := 0; i < 10; i++ {
		//wg.Add(1)
		go func() {
			//defer wg.Down()
			//mu.Lock()
			value++
			//mu.Unloock()
			fmt.Println(value)
		}()
	}
	fmt.Printf("\nFinish value=%d", value)
}
```
Что здесь не так, как исправить, чтобы все работало корректно.

_Ответ:_

Основная проблема заключается в том, что несколько горутин одновременно инкрементируют одну и ту же переменную, что
может привести к гонке данных (data race).
Это может привести к неопределенному поведению и некорректным результатам при выводе значения value.

1. Гонка данных: Несколько горутин могут одновременно изменять переменную value, что приводит к некорректным значениям.
2. Неопределенный порядок выполнения: Порядок выполнения горутин не гарантирован, и вывод может быть непредсказуемым.

**Решение с использованием sync**
```go
func main() {
 var value int
 var mu sync.Mutex
 var wg sync.WaitGroup

 for i := 0; i < 10; i++ {
  wg.Add(1)
  go func() {
   defer wg.Done()
   mu.Lock()
   value++
   mu.Unlock()
   fmt.Println(value)
  }()
 }

 wg.Wait() // Ждем завершения всех горутин
 fmt.Printf("\nFinish value=%d", value)
}
```

**Решение без использования sync**
**Использование канала**: Можно создать канал для передачи значений и инкрементирования переменной через него.
```go
func main() {
 valueChan := make(chan int)
 
 go func() {
  value := 0
  for i := 0; i < 10; i++ {
   value++
   valueChan <- value
  }
  close(valueChan) // Закрываем канал после завершения работы
 }()

 for v := range valueChan {
  fmt.Println(v)
 }

 fmt.Printf("\nFinish value=%d", 10) // Ожидаем, что value будет равно 10
}
```

Атомарные операции:  Можно использовать атомарные операции  для безопасного инкрементирования (как в пакете sync/atomic)
```go
import (
 "fmt"
 "sync/atomic"
)

func main() {
 var value int32

 for i := 0; i < 10; i++ {
  go func() {
   atomic.AddInt32(&value, 1)
   fmt.Println(atomic.LoadInt32(&value))
  }()
 }

 // Подождем некоторое время, чтобы все горутины завершились
 ...
 select {}
}
```

---

#### Задание 3

```go
func setMode(cM **int) {
	nM := 100
    *cM = &nM
}

func main() {
	coreMode := 1
	currentMode := &coreMode
	fmt.Println(*currentMode)

	setMode(currentMode)//setMode(&currentMode)
	fmt.Println(*currentMode)
}
```

Что отобразит программа и как нужно изменить код, чтобы вывелось

```shell
1
100
```

_Ответ:_

функция setMode изменяет указатель cM, но это изменение не отражается на переменной currentMode в функции main, так как указатели
передаются по значению. Поэтому при вызове setMode(currentMode) оригинальный указатель currentMode в main остается
указывать на coreMode, который равен 1.
Чтобы изменить значение, на которое указывает указатель currentMode в функции main, вы можете передать указатель на указатель (т.е. **int).

```go
func main() {
	coreMode := 1
	currentMode := &coreMode
	fmt.Println(*currentMode)

	setMode(&currentMode) // Передаем указатель на указатель
	fmt.Println(*currentMode)
}

func setMode(cM **int) {
	nM := 100
	*cM = &nM // Изменяем указатель, на который указывает cM
}
```

Изменение сигнатуры функции: Мы изменили тип параметра cM на **int, чтобы передать указатель на указатель.
Изменение значения: Внутри функции мы теперь можем изменить указатель, на который указывает cM, присваивая ему адрес новой переменной nM.


Теперь, когда вы выполните этот код, он выведет:

```shell
1
100
```



---

#### Задание 4

```go
func mySleep() (r chan struct{}) {
    r = make(chan struct{})

    go func() {
        time.Sleep(2 * time.Second)
        r <- struct{}{}
    }()

    return r
}

func main() {
    StartTM := time.Now()

    _, _, _ = <-mySleep(), <-mySleep(), <-mySleep()

    fmt.Println(int(time.Since(StartTM).Seconds()))
}
```

Что выведет код?
Как изменить код, чтобы вывело 2.

_Ответ:_

В функции main вы ждете завершения трех горутин (последовательно), что приводит к тому, что общее время ожидания
составляет 6 секунды (по 2 секунды на каждую горутину).

Чтобы код работал за 2 секунды, вам нужно изменить логику так, чтобы обе горутины выполнялись параллельно
и ожидались одновременно. Вы можете сделать это, используя один канал для синхронизации.

```go
func mySleep() chan struct{} {
 r := make(chan struct{})

 go func() {
  time.Sleep(2 * time.Second)
  r <- struct{}{}
 }()

 return r
}

func main() {
 StartTM := time.Now()

 // Создаем три канала, но ждем только один
 done1 := mySleep()
 done2 := mySleep()
 done3 := mySleep()

 // Ожидаем завершения всех
 <-done1
 <-done2
 <-done3

 fmt.Println(int(time.Since(StartTM).Seconds()))
}
```

---


#### Задание 5

Какой бедет вывод у кода

```go
func main() {
	fmt.Println("start")

	value := "-R"

	for i := 1; i < 6; i++ {
		defer fmt.Println(i)
	}

	defer func() {
		fmt.Printf("changed value: %s\n", value)
	}()

	defer fmt.Println("old value:", value)

	value = "-100"

	fmt.Println("stop")
}
```

defer добавляет переданную после него функцию в стэк.
При возврате внешней функции, вызываются все, добавленные в стэк вызовы.
Поскольку стэк работает по принципу LIFO (last in first out), значения стэка возвращаются в порядке от последнего к первому.

Таким образом функции c deferбудут вызываться в обратной последовательности от их объявления во внешней функции.
На этот вопрос любят давать практические задачи.

Аргументы функций, перед которыми указано ключевое слово defer оцениваются немедленно.
То есть на тот момент, когда переданы в функцию.

```
start
stop
old value: -R
changed value: -100
5
4
3
2
1

```

---

### Задание 6

Что выведет код

```go
func main() {
	data := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

	slice1 := data[2:]
	slice1[0] = 1000

	fmt.Println(slice1, len(slice1), cap(slice1))
	fmt.Println(data)

	slice2 := data[0:1]
	slice2 = append(slice2, 2000)
	fmt.Println(slice2, cap(slice2), len(slice2))
	fmt.Println(data)

	slice2 = append(slice2, []int{3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000}...)
	slice2[0] = 555
	fmt.Println(slice2, cap(slice2), len(slice2))
	fmt.Println(data)

	changeSliceV1(data)
	fmt.Println(data)

	changeSliceV2(data)
	fmt.Println(data)

	data = changeSliceV3(data)
	fmt.Println(data)

	changeSliceV4(&data)
	fmt.Println(data)
}

func changeSliceV1(inputData []int) {
	inputData[0] = 333
}

func changeSliceV2(inputData []int) {
	inputData = append(inputData, 99999)
}

func changeSliceV3(inputData []int) []int {
	inputData = append(inputData, 99999)
	return inputData
}

func changeSliceV4(inputData *[]int) {
	*inputData = append(*inputData, 777777)
}
```

---

### Задание 7

Что выведет код и почему

```go
func F1() {
	origin := []int{}
	fmt.Println(origin, cap(origin), len(origin))
	origin = append(origin, 0)
	fmt.Println(origin, cap(origin), len(origin))
	origin = append(origin, 1)
	fmt.Println(origin, cap(origin), len(origin))
	origin = append(origin, 2)
	fmt.Println(origin, cap(origin), len(origin))
	new_1 := append(origin, 3)
	//new_1[0] = 1000
	fmt.Println("new_1", new_1, cap(new_1), len(new_1))
	fmt.Println(origin, cap(origin), len(origin))
	new_2 := append(origin, 4)
	//new_2[0] = 100000
	fmt.Println("new_2", new_2, cap(new_2), len(new_2))
	fmt.Println(origin, cap(origin), len(origin))
	fmt.Println(new_1, new_2)
}

func main() {
	F1()
}
```

_Ответ:_

```
[] 0 0
[0] 1 1
[0 1] 2 2
[0 1 2] 4 3
new_1 [0 1 2 3] 4 4
[0 1 2] 4 3
new_2 [0 1 2 4] 4 4
[0 1 2] 4 3
[0 1 2 4] [0 1 2 4]
```





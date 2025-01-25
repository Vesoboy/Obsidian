Пример proto файла из проекта [[Project/gw-exchanger/Readme]], для сервиса с пользователями у которых есть кошельки,

![[user.proto]]

3 сервиса
	`// Определение сервиса`
		`service ExchangeService {`
		    `// Получение курсов обмена всех валют`
		    `rpc GetExchangeRates(RatesRequest) returns (ExchangeRatesResponse);`
		
		    `// Обмен валют`
			`rpc ExchangeCurrency(ExchangeRequest) returns (TransactionResponse);`
		`}`
	
	`// Auth сервиса`
		`service Auth{`
		    `// Регистрация пользователя`
		    `rpc RegisterUser(RegisterRequest) returns (RegisterResponse);`
		    `// Авторизация пользователя`
		    `rpc LoginUser(LoginRequest) returns (LoginResponse);`
		`}`
	
	`// Финансовые операции (Баланс, пополнение, вывод)`
		`service FinancialService {`
		    `// Получение баланса пользователя`
		    `rpc GetBalance(GetBalanceRequest) returns (BalanceResponse);`
		    
		    ``// Пополнение счета``
		    ``rpc Deposit(DepositRequest) returns (WithdrawDepositResponse);``
		
		    ``// Вывод средств``
			``rpc Withdraw(WithdrawRequest) returns (WithdrawDepositResponse);``
		``}``
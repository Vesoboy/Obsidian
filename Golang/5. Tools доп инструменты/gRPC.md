# 1. **Определение `.proto` файлов**

- Пример:
    
    proto
    
    syntax = "proto3"; 
    service Greeter { 
	    rpc SayHello (HelloRequest) returns (HelloReply); 
	} 
	message HelloRequest { 
		string name = 1; 
	} 
	message HelloReply { 
		string message = 1; 
	}
    

# 2. **Генерация кода через `protoc`**

- Установить `protoc` и плагин для Go:
    
    bash
    
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest 
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    
- Генерация:
    
    bash
    
    protoc --go_out=. --go-grpc_out=. ./greeter.proto
    

# 3. **Реализация клиента и сервера**

- Сервер:
    
    go

	type server struct {
	  pb.UnimplementedGreeterServer
	}
	
	func (s `*`server) SayHello(ctx context.Context, req `*`pb.HelloRequest) (`*`pb.HelloReply, error) {
	  return &pb.HelloReply{Message: "Hello " + req.Name}, nil
	}


    
- Клиент:
    
    go
    
    conn, _ := grpc.Dial(":50051", grpc.WithInsecure()) 
    client := pb.NewGreeterClient(conn)`
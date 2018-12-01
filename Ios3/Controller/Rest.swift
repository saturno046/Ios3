//
//  Rest.swift
//  Carangas
//
//  Created by Lucas Ventura on 01/12/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

enum CarError {
    case url
    case taskError(error: NSError)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

class Rest {
    // nao quer expor para fora da class
    private static let basePath = "http://localhost:3333/carros"
    
    private static let configuration: URLSessionConfiguration = {
        
        // configuracoes padroes
        // default sao configuracoes padroes para conexao
        // ephemeral sao configuracoes em modo privado, nada fica armazenado localmente "trafego anonimo"
        // background sao configuracoes quando o app nao ta sendo utilizado e esta pedindo informacoes para o servidor "notificacao"
        
        let config = URLSessionConfiguration.default
        
        config.allowsCellularAccess = false // nao permite o acesso por celular "3g"jeito de impedir que o usuario nao gaste o trafego de dados dele
        config.httpAdditionalHeaders = ["Content-Type":"applications/json"] // informa que os dados que estao sendo trafegados nessa secao, sao do tipo JSON
        // quando utilizado informa a session que obrigatoriamente na requisicao o cabecalho sera essa configuracao
        config.timeoutIntervalForRequest = 30.0 // informa que tera 30 segundos para requisicao. se em 30 minutos eu nao tiver nenhuma resposta significa que sera cancelada a requisicao
        config.httpMaximumConnectionsPerHost = 5 // quantidade de conexoes por sessao ao mesmo tempo. exp 5 downloads ao mesmo tempo
        return config
        
    }()
    //crio secao compartilhada
    //private static let session = URLSession.shared
    
    //criar secao do zero
    
    private static let session = URLSession(configuration: configuration)
    
    class func loadCars(onComplete : @escaping ([Car]) -> Void, onError : @escaping (CarError) -> Void){
        // pode retorna nulo por isso ta usando o guard
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        
        // apos dar enter no completionHandler e criado essa clousure
        // data = informacoes que o servidor devolve "propio json"
   
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?,error: Error?) in
           
            if error == nil {
            
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return}
                // validando resposta do servidor
                if response.statusCode == 200 {
                    guard let data = data else {
                        onError(.responseStatusCode(code: response.statusCode))
                        return}
                    
                    do{
                        let carro = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(carro)
                    }catch{
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                }else {
                    
                    let status = response.statusCode
                    print(status)
                    print("Algum status inválido pelo servidor!!" )
                }
                
            }else{
                onError(.taskError(error: error! as NSError))
            }
        }
        dataTask.resume() // esse metodo que executa a tarefa e manda a requisicao para o servidor
        
    }
    
    class func Salva(car: Car, onComplete:  @escaping (Bool) -> Void){
        
        guard let url = URL(string: basePath) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request.httpBody = json
        // quando for criar um metodo que nao seja o get para fazer um requisicao com o servidor
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else{
                    onComplete(false)
                    return
                }
                onComplete(true)
            }else{
                // avisa a tela
                onComplete(false)
            }
        }
        dataTask.resume()
    }
}

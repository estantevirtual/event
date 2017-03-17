[![Build Status](https://semaphoreapp.com/api/v1/projects/3b801a94-a652-4c1d-b347-ff6006adaf43/364951/shields_badge.svg)](https://semaphoreapp.com/darkseid/event)
# Event

O objetivo desta GEM é permitir que as Engines que compõem a nova Plataforma da Estante Virutal possam se comunicar sem que estas precisem "se conhecer", garantindo assim um baixo acoplamento entre as Engines.

A solução é baseada no pattern Publish-Subscribe Channel descrito pelo Fowler em seu livro Enterprise Integration Patterns. No caso, o papel do MessageChannel será exercido pelo RabbitMQ.

## Instalação

Como dito anteriormente, esta gem utiliza o RabbitMQ. Por isso precisamos ter esta dependência instalada. Para realizar a instalação basta seguir o passo a passo descrito neste [link](https://www.rabbitmq.com/download.html)

Depois, você precisa adicionar um novo source ao seu Gemfile. Este novo source deve ser a primeira linha do seu Gemfile:

```ruby
source 'https://repo.fury.io/sergioazevedo'
source 'https://rubygems.org'
```

Se vc estiver instalando em uma Engine deve alterar o arquivo 'suaengine.gemspec' e adicionar a dependencia

```ruby
s.add_dependency "event","~>1.0.0"
```

Caso seja um projeto Ruby normal ou uma Rails app adicione a linha abaixo no seu Gemfile:

```ruby
gem "event","~>1.0.0"
```

E executar:
    $ bundle 

## Configuração
Os arquivos abaixo são necessários para se configurar esta gem.
```
config/event.yml
config/initializes/setup_event.rb
```

Para gerá-los basta rodar a rake task: ```rake app:event:install```.  

####config/event.yml
Neste arquivo você deve fornecer as configuracoes para conexão com o Broker RabbitMQ.
Mas este arquivo contém uma configuração muito importante, e está na chave: **base_routing_key**. Você **precisa** usar nesta chave o nome da sua engine _(ou algo semelhante, que identifique o módulo)_.
Exemplo:
Imagine o modulo de Ecommerce

```yaml
development:
  base_routing_key: ecommerce
  broker:
    ip: localhost
    port: 5672
    username: guest
    password: guest
```

####config/initializers/setup_event.rb
Você só vai precisar alterar este arquivo no caso de querer "assinar" algum evento.

## Utilização

### Publicando Eventos / Enviando mensagens
Publicar eventos é muito fácil, basta usar Event.pubish.

```ruby
  Event.publish(:sku_added, name: 'Caneta Azul', price: 1.99, qty: 10 )
```
No exempo acima o nome do evento é **:sku_added** e os dados do evento estão no hash: **{name: 'Caneta Azul', price: 1.99, qty: 10}**

###Sobre os Eventos 
Eventos são sempre coisas que já aconteceram, por este motivo é de boa prática que os nomes dos eventos descrevam claramente que fato ocorreu e com quem. Exemplos abaixo:
 - Um produto novo sku foi adicionado - :new_product_added
 - Um sku novo foi adicionado - :new_sku_added
 - Um sku foi vendido - :sku_saled
 - Produto teve seu preço alterado - product_price_updated
 
Sobre os dados do evento, isto fica a cargo de quem publica o evento. Mas em geral é bacana enviar informações sobre o contexto do evento. 

Exemplo:

- Um sku foi vendido
```ruby
Event.publish(:sku_saled, sku_id: 10 )
```
- Preço de um sku foi alterado  
```ruby
Event.publish(:sku_price_changed, sku_id: 10, old_price: 1.99, new_price: 2.87 )
```
  
### Assinando os Eventos / Recebendo mensagens

Assinar eventos é um processo de duas etapas:  

1. Escrever uma classe Listener para o evento desejado  
2. Registrar o Listener para o evento desejado em config/initializes/setup_event.rb

####1. Escrever uma classe Listener para o evento desejado
Como dito antes você vai precisar escrever uma classe para cada listener que desejar.
Esta classe não precisa herdar de nada, basta que ela tenha os métodos **#initialize** e **notify**. O Listener é como um [Observer _GoF_](http://en.wikipedia.org/wiki/Observer_pattern).

Atenção, o listener deve receber toda a informação necessária para sua excução no método de inicialização (new), ou seja, os dados do evento/mensagem.

Exemplo de Listener:

Considere a mensagem abaixo:

```ruby
Event.publish(:sku_price_changed, sku_id: 10, old_price: 1.99, new_price: 2.87 )
```


```ruby
class SkuPriceChangedListener
  def initialize(data={})
    @sku_id = data[:sku_id]
    @old_price = data[:old_price]
    @new_price = data[:new_price]
  end

  def notify
    #aqui vai o seu código.
    #vc pode, e em geral vai acontecer isso, instanciar um UseCase e executa-lo.
  end
end
````

##### As Operações executadas por um listener devem ser Idempotentes sempre!!!
Por razões de segurança, e para garantia da consistencia dos nossos dados, as operações realizadas por um Listener deve ser idempontentes.

>Idempotente quer dizer que múltiplas requisições ao mesmo recurso usando o método devem ter o mesmo resultado que teria uma requisição apenas. A título de curiosidade, idempotente é a propriedade de um número que, multiplicado por ele mesmo, tem ele mesmo como resultado (n x n = n), em termos de números reais, apenas 0 e 1 têm essa propriedade. Em termos de métodos de requisição HTTP, os métodos GET, HEAD, PUT e DELETE são os que possuem a propriedade de ser idempotentes
- <cite>[Dicionario Informal](http://www.dicionarioinformal.com.br/idempotente/)</cite>

##### Onde colocar meus listeners
Em geral, costuma-se criar dentro de app/ uma pasta chamada listeners ou event_listeners.

####2. Registrar o Listener para o evento 
No arquivo setup_events.rb existe uma seção dedicada ao registro dos listeners.
Esta seção vem toda comentada por padrão, veja:
```ruby
  # Register your listeners Here!!!! Example:
  # Event.register_listeners do |config|
  #   config.add_listeners(:event_name, ['EventNameListener'])
  #   config.add_listeners(:another_event_name, ['AnotherEventListener1', 'Listner2'])
  # end
```
Basta descomentar e seguir como no exemplo. Imaginando que queremos registrar o nosso SkuPriceChangedListener, esta configuracao ficaria assim:

```ruby
  # Register your listeners Here!!!! Example:
  Event.register_listeners do |config|
    config.add_listeners(:sku_price_changed, ['SkuPriceChanged'])
  end
```

**Note que você sempre deve fornecer o nome do Listener com uma String dentro de um Array.**

**Observação:** Como este arquivo setup_events.rb é carregado na inicialização da aplicação, toda vez que você registrar um evento novo vai precisar reinicar a app.

**Observação:** Atualmente, o producer só consegue enviar mensagens caso haja um consumer.


## Contributing
1. Fork it ( https://github.com/[my-github-username]/event/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

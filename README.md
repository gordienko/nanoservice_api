# Наносервис

Прототип микросервиса, обеспечивающий эмуляцию отправки сообщений в популярные сервисы 
instant messaging (Viber, Telegram, What’s App).

## Установка

```
$ bundle install
$ gem install foreman

$ rake db:create
$ rake db:migrate

$ rspec
```

## Настройка

В приложении для доступа к API, а так-же для доступа к мониторингу Sidekiq используется базовая HTTP аутентификация.
Настройки доступа безопасно хранятся в config/credentials.yml.enc, для правки, нужно использовать команду:
```shell script
$ EDITOR=vim rails credentials:edit
```

Необходимо определить параметры доступа, аналогично тому, как показано ниже:


```yaml
username: admin
password: Pas$W0rd
```

## Использование

Запускаем сервер.
```shell script
$ foreman start -f Procfile.dev
```

Отправка сообщения, не забываем, про необходимость использовать базовую HTTP аутентификацию. 

POST http://localhost:3000/api/v1/messages
```json
{
    "body": "Как здорово что все мы здесь сегодня собрались!",
	"dispatches_attributes": [
		{
			"phone": "+79308409858",
			"messenger_type": "telegram"
		},
		{
			"phone": "+79308409858",
			"messenger_type": "viber"
		},
		{
			"phone": "+79308509158",
			"messenger_type": "telegram",
			"send_at": "2020-10-20T13:25:57.083Z"
		},
		{
			"phone": "+79308509258",
			"messenger_type": "whatsapp"
		}
	]
}
```

Ответ сервера, при отсутствии проблем с валидацией, будет выглядеть примерно вот так:

```json
{
  "messages": "Message sent for processing",
  "is_success": true,
  "data": {
    "message": {
      "id": 17,
      "body": "Как здорово что все мы здесь сегодня собрались!",
      "created_at": "2020-10-08T13:43:40.476Z",
      "updated_at": "2020-10-08T13:43:40.476Z",
      "dispatches": [
        {
          "id": 65,
          "message_id": 17,
          "phone": "+79308409858",
          "messenger_type": "telegram",
          "send_at": null,
          "status": "pending",
          "created_at": "2020-10-08T13:43:40.477Z",
          "updated_at": "2020-10-08T13:43:40.477Z"
        },
        {
          "id": 66,
          "message_id": 17,
          "phone": "+79308409858",
          "messenger_type": "viber",
          "send_at": null,
          "status": "pending",
          "created_at": "2020-10-08T13:43:40.478Z",
          "updated_at": "2020-10-08T13:43:40.478Z"
        },
        {
          "id": 67,
          "message_id": 17,
          "phone": "+79308509158",
          "messenger_type": "telegram",
          "send_at": "2020-10-20T13:25:57.083Z",
          "status": "pending",
          "created_at": "2020-10-08T13:43:40.480Z",
          "updated_at": "2020-10-08T13:43:40.480Z"
        },
        {
          "id": 68,
          "message_id": 17,
          "phone": "+79308509258",
          "messenger_type": "whatsapp",
          "send_at": null,
          "status": "pending",
          "created_at": "2020-10-08T13:43:40.481Z",
          "updated_at": "2020-10-08T13:43:40.481Z"
        }
      ]
    }
  }
}
```

Если возникнут проблемы с аутентификацией, ответ будет таким:

```json
{
  "messages": "Invalid credentials",
  "is_success": false,
  "data": {}
}
```

Если в списке будет присутствовать получатель с учетом номера и типа мессенджера, которому 
ранее уже было отправлено сообщение, ВСЯ отправка будет отклонена, пример ответа ниже:  

```json
{
  "messages": {
    "dispatches.phone": [
      "A similar message using whatsapp has already been sent to +79308509258"
    ]
  },
  "is_success": false,
  "data": {}
}
```

Вообще, для обеспечения консистентности данных, каждый API запрос выполняется в рамках одной транзакции, поэтому, 
если какой либо из параметров не пройдет валидацию, отклоняетются все отправки входящие в запрос.
Считаю, что в данной задаче, это наиболее правильный вариант.

Очереди построены с помощью Sidekiq, для каждого типа мессенджера отдельная очередь. 
Доступ в веб панель Sidekiq находится по этому адресу http://localhost:3000/sidekiq, также закрыта 
Basic access authentication. 
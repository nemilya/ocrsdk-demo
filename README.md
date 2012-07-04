abbyysdk/ocrsdk demo
====================

Демо приложение: http://ocrsdk-demo.cloudfoundry.com

Демонстрация использования сервиса распознавания от ABBYY:
http://ocrsdk.com/

За базу был взять пример из SDK Samples для Ruby:
https://github.com/abbyysdk/ocrsdk.com/tree/master/Ruby


Используется набор `picture_samples` предоставляемый для тестирования
http://ocrsdk.com/documentation/sample-images/

Обработка этих изображений не тарифицируется.

По умолчанию на бесплатном тарифном плане доступно обработка 50 страниц.

Подробнее по ценам здесь:

http://ocrsdk.com/plans-and-pricing/



Приложение
==========

Структура файлов:

    /config
      ocr_sdk.yml
      ocr_sdk.yml.template
      picture_samples.yml
    /lib
      ocr_client.rb
    /public
      /picture_samples
        /Arabic
        /Chinese
        /English
        /French
        /German
        /Italian
        /Japanese
        /Korean
        /Russian
        /Spanish        
    /views
    app.rb
    helpers.rb
    README.md

Приложение на Ruby фреймворке (Sinatra)[http://sinatraruby.ru].

В папке `config` находится `ocr_sdk.yml` - с ид приложения и паролем,
их необходимо получить после регистрации на сайте.

`picture_samples.yml` - конфиг файл со списком демо картинок для распознавания
(пока там не все включены, можно будет указывать тип - для применения разных типов
распознавания - текст, штрих код, и т.п.)

`lib/ocr_client.rb` - это простой клиент, к API - используется 2 метода - регистарция 
задачи на распознавание (передаётся ид приложения, пароль, язык, путь к файлу), 
возвращается id задачи, и второй метод - по ид задачи получение статуса задачи,
когда задача выполняется - то в xml можно получить url с которого можно 
скачать результат выполнения - результат распознавания.

`public/picture_samples` - в этой папке находится распакованный архив
http://ocrsdk.com/help/picture_samples.zip (http://ocrsdk.com/documentation/sample-images/)


Настройка
=========

Для настройки - необходимо переименовать `config/ocr_sdk.yml.template` в
`config/ocr_sdk.yml` и указать ид приложения и пароль.

Распаковать архив демо приложений в папку `picture_samples`. (либо настроить на
свои изображения - тогда необходимо изменить файл `config/picture_samples.yml`



Развёртывание на cloudfoundry.com
=================================

(CloudFoundry)[http://cloudfoundry.com] - это облачный сервис предоставляющий 
бесплатный хостинг на SaaS платформе CloudFoundry.

Необходимо получить аккаунт на cloudfoundry.com, после этого установить гем
`vmc`. 

После этого выполнить упаковку gem'ов: 

    bundle package

После этого развёртываем приложение на Cloudfoundry, на все вопросы отвечаем по дефолту:

    vmc push your-app-name

Здесь `your-app-name` имя вашего приложение, после этого оно должно быть доступно
по адресу http://your-app-name.cloudfoundry.com

Перед этим должен быть настроен конфиг файл с ид приложение и паролем для
доступа к SDK, и настроен файл `config/picture_samples.yml` - 
соответственно должена быть папка с этими файлами (я загрузил для демки - не все демо-файлы,
для уменьшения общего размера приложения).


Для деплоя приложения после какого либо изменения в файлах:

    vmc update your-app-name

Автоматически будут загружены изменённые файлы, и перестартовано приложение.


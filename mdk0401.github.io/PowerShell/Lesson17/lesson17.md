# Урок 17. Работа и настройка оболочки PowerShell

[На главную](/mdk0401.github.io)

## Автоматическое завершение команд 
Находясь в оболочке `PowerShell`, можно ввести часть какой-либо команды, нажать клавишу `Tab`, и система попытается сама завершить эту команду. 

Во-первых, автоматическое завершение срабатывает для имен файлов и путей файловой системы (подобный режим поддерживался и в оболочке `cmd.exe`). При нажатии клавиши `Tab` `PowerShell` автоматически расширит частично введенный путь файловой системы до первого найденного совпадения. При повторном нажатии клавиши `Tab` производится циклический переход по имеющимся возможностям выбора. 

```powershell
cd 'C:\Program Files'
```

Во-вторых, в `PowerShell` реализовано автоматическое завершение имен командлетов и их параметров. Если ввести первую часть имени командлета (глагол) и дефис, нажать после этого клавишу `Tab`, то система подставит имя первого подходящего командлета 

```powershell
Get-<Tab>
```

Аналогичным образом автоматическое завершение срабатывает для частично введенных имен параметров командлета

```powershell
Get-Process -<Tab>
```

В-третьих, `PowerShell` позволяет автоматически завершать имена используемых переменных. 

```powershell
$mystr='asdfg'
$my<Tab>
```

Наконец, PowerShell поддерживает автоматическое завершение имен свойств и методов объектов

```powershell
$mystr.<Tab>
```

## Справочная система PowerShell 
При работе с интерактивной командной оболочкой очень важно иметь под рукой подробную и удобную справочную систему с описанием возможностей команд и примерами их применения. В `PowerShell` такая система имеется, здесь предусмотрено несколько способов получения справочной информации внутри оболочки.

Краткую справку по какому-либо одному командлету можно получить с помощью параметра `-?` (вопросительный знак), указанного после имени этого командлета.

```powershell
Get-Host -?
```

В этой справке кратко описывается интересующий командлет и приводятся допустимые варианты его синтаксиса. Необязательные параметры выводятся в квадратных скобках. Если для параметра необходимо указывать аргумент определенного типа, то после имени такого параметра в угловых скобках приводится название этого типа. 

Для получения подробной информации о командлете служит специальный командлет `Get-Help`, который следует запускать с параметрами `-Detailed` или `-Full`. Ключ `-Full` приводит к выводу всей имеющейся справочной информации, а при использовании ключа `-Detailed` некоторая техническая информация опускается. В обоих случаях будут выведены подробные описания каждого из параметров, поддерживаемых рассматриваемым командлетом, различные замечания, а также приведены примеры запуска данного командлета с различными параметрами и аргументами.

```powershell
Get-Help Get-Command -Detailed
```

## Протоколирование действий в сеансе работы 
В оболочке `PowerShell` можно записывать в текстовый файл не только запускаемые команды, но и результат их выполнения, то есть сохранять в файле весь сеанс работы или какую-либо его часть. Для этой цели служит командлет `Start-Transcript`, имеющий следующий синтаксис (указаны только основные параметры)

```powershell
Start-Transcript [[-Path] <строка>] [-NoClobber] [-Append] 
```

Параметр `Path` здесь задает путь к текстовому файлу с протоколом работы (путь должен быть указан явно, подстановочные знаки не поддерживаются).

```powershell
Start-Transcript
Транскрибирование запущено, выходной файл C:\Users\root\Documents\PowerShell_transcript.IAI.Ojnlm81e.20231025085157.txt
...
...
...
Stop-Transcript
Транскрибирование остановлено, выходной файл C:\Users\root\Documents\PowerShell_transcript.IAI.Ojnlm81e.20231025085157.txt
```

Если имя для файла протокола не указано, то он будет сохраняться в файле, путь к которому задан в значении глобальной переменной `$Transcript`. Если эта переменная не определена, то командлет `Start-Transcript` сохраняет протоколы в каталоге *"$Home\Мои документы"* в файлах *"PowerShell_ transcript.<метка-времени>.txt"* (в переменной `$Home` хранится путь к домашнему каталогу работающего пользователя).

## Программное изменение свойств консоли PowerShell 
Система `PowerShell` позволяет настраивать различные параметры командного окна (размер, цвет текста и фона, вид приглашения и т. п.) непосредственно из оболочки. Для этого можно воспользоваться командлетом `Get-Host`, который по умолчанию выводит информацию о самой оболочке PowerShell (версия, региональные настройки и т. д.)

```powershell
Get-Host
```

Нам понадобится свойство `UI` (это объект .NET-класса `System.Management. Automation.Internal.Host.InternalHostUserInterface`). В свою очередь объект `UI` имеет свойство `RawUI`, позволяющее получить доступ к параметрам командного окна `PowerShell`. 

```powershell
(Get-Host).UI.RawUI
```

> [!NOTE]
> В последней команде командлет `Get-Host` был заключен в круглые скобки. Это означает, что система вначале запускает данный командлет и получает выходной объект в результате его работы. Затем извлекается свойство `UI` данного объекта (объект `UI`) и свойство `RawUI` объекта `UI`. 

На экран выводятся значения свойств объекта `RawUI`. Многие свойства объекта `RawUI` можно изменять, настраивая тем самым соответствующие свойства командного окна.

За цвет текста в командном окне `PowerShell` отвечает свойство `ForegroundColor` объекта `RawUI`, а за цвет фона — свойство `BackgroundColor`. 

Для изменения данных свойств удобнее предварительно сохранить объект `RawUI` в отдельную переменную 

```powershell
$ui=(Get-Host).UI.RawUI 
```

Теперь можно присвоить свойствам новые значения. 

`PowerShell` поддерживает 16 цветов, которым соответствуют следующие символьные константы: *Black*, *Gray*, *Red*, *Magenta*, *Yellow*, *Blue*, *Green*, *Cyan*, *White*, *DarkGreen*, *DarkCyan*, *DarkRed*, *DarkMagenta*, *DarkYellow*, *DarkGray* и *DarkBlue*. 

```powershell
$ui.BackgroundColor = 'Gray'
```

По умолчанию в заголовке командного окна отображается строка *"Windows PowerShell"*. Для изменения этого заголовка нужно записать новое значение в свойство `WindowTitle` объекта `RawUI`

```powershell
$ui=(Get-Host).UI.RawUI 
$ui.WindowTitle = 'Hello world!!'
```

Размеры окна `PowerShell` хранятся в свойстве `WindowSize` объекта `RawUI` в виде пары чисел: количество символов в строке и количество строк в окне. 

На самом деле свойство `WindowSize` — это тоже **объект**, имеющий свойства `Width` и `Height`

```powershell
$ui=(Get-host).UI.RawUI

$ws=$a.WindowSize
$ws.Width=30
$ws.Height=10

$ui.WindowSize=$ws
```

## Политики выполнения сценариев 
Политика выполнения (*execution policy*) оболочки `PowerShell` определяет, можно ли на данном компьютере выполнять сценарии `PowerShell`, и если да, должны ли они быть подписаны цифровой подписью. 

Политика выполнения `PowerShell` хранится в реестре операционной системы и не удаляется даже при переустановке оболочки `PowerShell`. 

Возможные политики выполнения `PowerShell`

| Название политики | Описание |
| :--: | :-- |
| **Restricted** | Данная политика выполнения используется по умолчанию, она запрещает выполнение сценариев и загрузку профилей (можно пользоваться только одиночными командами `PowerShell` в интерактивном режиме) |
| **AllSigned** | Выполнение сценариев `PowerShell` разрешено, однако все сценарии (как загруженные из Интернета, так и локальные) должны иметь цифровую подпись надежного издателя. Перед выполнением сценариев надежных издателей запрашивается подтверждение |
| **RemoteSigned** | Выполнение сценариев `PowerShell` разрешено, при этом все сценарии и профили, загруженные из Интер- нета (в том числе по электронной почте и с помощью программ мгновенного обмена сообщениями), должны иметь цифровую подпись надежного издателя, а локальные сценарии могут быть неподписанными. При запуске сценариев надежных издателей подтверждение не запрашивается |
| **Unrestricted** | Разрешается выполнение любых сценариев `PowerShell` без проверки цифровой подписи. При запуске сценариев и профилей, загруженных из Интернета, выдается предупреждение|

Узнать, какая политика выполнения является активной, можно с помощью командлета `Get-ExecutionPolicy`

```powershell
Get-ExecutionPolicy
```
По умолчанию действует политика `Restricted`, запрещающая запуск любых сценариев `PowerShell`, включая пользовательские. 

Командлет `Set-ExecutionPolicy` позволяет сменить политику выполнения.

```powershell
Set-ExecutionPolicy RemoteSigned
```

## Windows PowerShell ISE
**Windows PowerShell ISE** — это приложение с графическим интерфейсом, которое используется для запуска и отладки команд и сценариев. 

Интегрированная среда сценариев **Windows PowerShell ISE** является ведущим приложением для `PowerShell`. В ISE можно запускать команды, записывать и тестировать скрипты, а также выполнять их отладку в едином графическом пользовательском интерфейсе на базе Windows. ISE поддерживает редактирование нескольких строк, заполнение нажатием клавиши `TAB`, раскраску синтаксических конструкций, выборочное выполнение, контекстную справку. Элементы меню и сочетания клавиш подходят для выполнения большинства тех же задач, которые выполняются в консоли `PowerShell`.

[![PowerShell Инструменты](https://img.youtube.com/vi/Mmg6HJgkcCI/hqdefault.jpg)](https://www.youtube.com/watch?v=Mmg6HJgkcCI)

# Урок 23. Удаленный запуск сценариев

[На главную](/mdk0401.github.io)

Если вы единственный ИТ-специалист в небольшой организации, скорее всего, вы ответственны за несколько серверов. Когда у вас есть сценарий, который необходимо запустить, вы заходите на каждый сервер, открываете консоль PowerShell и запускаете его. Однако можно сэкономить кучу времени, если запустить всего один сценарий, который будет выполнять определенную задачу на каждом сервере. 

В этой лекции мы рассмотрим, как удаленно запускать команды с помощью инструментов PowerShell. 

**Удаленное управление PowerShell** — это инструмент, который позволяет пользователю удаленно запускать команды на одном или нескольких компьютерах одновременно. 

Сеанс, или, если точнее, сеанс `PSSession`, — это взаимодействие со средой PowerShell, запущенной на удаленном компьютере, с которого вы можете выполнять команды. 

> [!NOTE]
> Сотрудники корпорации Microsoft внедрили удаленное управление в версии *PowerShell v2*. Оно было создано на основе службы *Windows Remote Management (WinRM)*. По этой причине удаленное управление PowerShell иногда ассоциируют с термином **WinRM**.

Но прежде, поговорим о...

## Удаленное взаимодействие с Windows PowerShell без настройки
Многие командлеты Windows PowerShell имеют параметр `ComputerName`, который позволяет собирать данные и изменять параметры одного или нескольких удаленных компьютеров. Эти командлеты используют разные протоколы связи и работают во всех операционных системах Windows без специальной настройки.

В эти командлеты входят следующие:

+ `Restart-Computer`
+ `Test-Connection`
+ `Clear-EventLog`
+ `Get-EventLog`
+ `Get-HotFix`
+ `Get-Process`
+ `Get-Service`
+ `Set-Service`
+ `Get-WinEvent`
+ `Get-WmiObject`

Обычно командлеты, которые поддерживают удаленное взаимодействие без специальной настройки, имеют параметр `ComputerName`, но не имеют параметра `Session`. Чтобы найти эти командлеты в сеансе, используйте следующую команду:

```powershell
Get-Command | Where-Object {
    $_.Parameters.Keys -contains "ComputerName" -and
    $_.Parameters.Keys -notcontains "Session"
}
```

## Удаленное взаимодействие Windows PowerShell
Функциональность удаленного выполнения команд в PowerShell называется PowerShell Remoting (появилась в PowerShell 2.0) и основана на возможностях протокола Web Services for Management (WS-Management). 

Благодаря использованию протокола WS-Management служба удаленного взаимодействия Windows PowerShell позволяет запустить любую команду Windows PowerShell на одном или нескольких удаленных компьютерах. Вы можете устанавливать постоянные подключения, запускать интерактивные сеансы и выполнять скрипты на удаленных компьютерах.

Чтобы использовать службу удаленного взаимодействия Windows PowerShell, удаленный компьютер должен быть настроен для удаленного управления. 

Для удаленного подключения к компьютеру через PowerShell на нем должна быть включена и настроена **WinRM** (служба удаленного управления Windows) (по умолчанию она отключена). Связь между компьютерами осуществляется по протоколам HTTP или HTTPS, а весь сетевой трафик между компьютерами зашифрован. 

Чтобы проверить состояние службы WinRM, выполните следующую команду

```powershell
Get-Service WinRM
```

Если служба не запущена, необходимо её запустить

```powershell
Start-Service WinRM
```

Либо воспользоваться командлетом `Enable-PSRemoting`

```powershell
Enable-PSRemoting
```

Командлет `Enable-PSRemoting` настраивает компьютер для получения удаленных команд PowerShell, отправляемых с помощью технологии WS-Management. 

> [!NOTE]
> На платформах Windows Server удаленное взаимодействие PowerShell по умолчанию включено. 

Эту команду необходимо выполнить только один раз на каждом компьютере, который будет принимать команды. Ее не нужно выполнять на компьютерах, которые только отправляют команды. Так как конфигурация запускает *прослушивание* для приема удаленных подключений.

> [!WARNING]
> Включение удаленного взаимодействия PowerShell в клиентских версиях Windows, если компьютер находится в общедоступной сети, обычно **запрещено**, но это ограничение можно пропустить с помощью параметра `SkipNetworkProfileCheck`. 

После настройки службы удаленного взаимодействия Windows PowerShell вы получите доступ ко многим стратегиям удаленного взаимодействия. 

## Работа с блоками сценариев
В удаленном управлении PowerShell широко используются блоки сценариев, которые, как и функции, представляют собой код, упакованный в единый исполняемый блок. Они отличаются от функций **парой важных деталей**: у них нет имени и их можно назначать переменным. 

Для создания блока сценария поместите код в фигурные скобки. Сохраним блок сценария в переменной. Вам может показаться, что для выполнения этого блока сценария можно просто вызвать переменную

```powershell
$block = { Write-Host "Hello, world" }
$block
```

PowerShell считывает содержимое переменной буквально, не понимая, что `Write-Host` — это команда, которую он должен выполнить. Вместо этого в консоли выводится содержимое блока сценария. 

Чтобы PowerShell запустил код внутри блока, вам нужно использовать символ `&`, за которым следует имя переменной.

```powershell
& $block
```

Этот символ сообщает PowerShell, что в фигурных скобках — это код, который надо выполнить. Это один из способов выполнения блока кода. Однако ему не хватает настроек, доступных для команд, которые вам понадобятся при работе с PowerShell на удаленных компьютерах.

## Использование команды Invoke-Command для выполнения кода на удаленных системах 
Команду `Invoke-Command` вы, вероятно, будете использовать чаще всего при удаленном управлении PowerShell. Существует два основных способа ее использования. Первый — для запуска так называемых *ad-hoc-команд* — небольших одноразовых выражений. Второй способ — для работы в интерактивных сеансах. 

Примером *ad-hoc-команды* является выполнение `Start-Service` для запуска службы на удаленном компьютере. Когда вы выполняете специальную команду с помощью `Invoke-Command`, PowerShell создает сеанс и разрывает его, как только команда будет выполнена. Это ограничивает разнообразие действий с `Invoke-Command`.

> [!IMPORTANT]
> Обратите внимание: для того чтобы Ваша команда сработала, оба компьютера должны быть частью одного домена *Active Directory (AD)*, при этом так же должны быть права администратора на удаленном компьютере

```powershell
Invoke-Command -ComputerName 250-prep -ScriptBlock {Get-Process} 
```

> [!WARNING]
> `Test-WSMan` - проверяет, запущена ли служба *WinRM* на локальном или удаленном компьютере.

```powershell
Test-WSMan -ComputerName "server01" -Authentication default
```

Обратите внимание, что теперь вывод команды — это вывод с удаленного компьютера.

## Запуск локальных сценариев на удаленных компьютерах 
Команду `Invoke-Command` также можно использовать для выполнения целых сценариев. Вместо параметра `Scriptblock` вы можете прописать параметр `FilePath` и указать путь к сценарию на вашем компьютере. 

При использовании параметра `FilePath` команда `Invoke-Command` считает содержимое сценария локально, а затем выполнит его код на удаленном компьютере. Сам сценарий на удаленном компьютере при этом не выполняется. 

```powershell
Invoke-Command -ComputerName 250-prep -FilePath C:\ps1\Get-HeavyProccess.ps1
```

Команда `Invoke-Command` запускает код из сценария *Get-HeavyProccess.ps1* на компьютере *250-prep* и возвращает результат в ваш локальный сеанс.

## Удаленное использование локальных переменных 
В удаленном управлении PowerShell предусмотрено много полезного, однако следует проявлять осторожность при использовании локальных переменных. Допустим, у вас есть путь к файлу на удаленном компьютере — *C:\File.txt*. Поскольку в какой-то момент этот путь может измениться, вы помещаете его в переменную, например в `$serverFilePath`

```powershell
$serverFilePath = 'C:\File.txt'
```

Теперь вам может потребоваться указать путь *C:\File.txt* внутри блока сценария на удаленном хосте

```powershell
Invoke-Command -ComputerName WEBSRV1 -ScriptBlock { Write-Host "The value of foo is $serverFilePath" }
```

Обратите внимание, что у переменной `$serverFilePath` **нет значения**, потому что при выполнении блока сценария на удаленном компьютере **этой переменной вообще не существует!** Когда вы определяете переменную в сценарии или в консоли, эта переменная сохраняется в определенной области выполнения. Она является своего рода контейнером, который PowerShell использует для хранения информации во время сеанса. 

Переменные, функции и другие конструкции по умолчанию не распространяются на несколько пространств выполнения. Однако существует несколько методов, позволяющих это сделать. Есть два основных способа передачи переменных на удаленный компьютер.

### Передача переменных с помощью параметра ArgumentList 
Чтобы получить значение переменной в удаленном блоке сценария, воспользуйтесь параметром `ArgumentList` команды `Invoke-Command`. Этот параметр позволяет передавать массив локальных значений `$args` в блок сценария, который в дальнейшем можно включать в код блока. 

```powershell
Invoke-Command -ComputerName WEBSRV1 -ScriptBlock { Write-Host "The value of foo is $($args[0])" } -ArgumentList $serverFilePath
```

Значение переменной *C:\File.txt* теперь находится внутри блока сценария. Это происходит потому, что мы передали `$serverFilePath` в `ArgumentList` и заменили ссылку `$serverFilePath` внутри блока сценария на `$args[0]`. Если вы хотите передать в блок сценария более одной переменной, добавьте другое значение к значению параметра `ArgumentList` и увеличьте ссылку `$args` на единицу там, где хотите сослаться на новую переменную.

### Использование оператора $Using для передачи значений переменных 
Другой способ передачи значений локальных переменных в удаленный блок сценария — использование оператора `$using`. Вам не понадобится использовать `ArgumentList`, если вы добавите оператор `$using` к любому имени локальной переменной. Прежде чем PowerShell отправит блок сценария на удаленный компьютер, он найдет оператор `$using` и раскроет все локальные переменные внутри этого блока.

```powershell
Invoke-Command -ComputerName WEBSRV1 -ScriptBlock { Write-Host "The value of foo is $using:serverFilePath" }
```

## Работа с сеансами 
В удаленном управлении PowerShell существует понятие сеанса. Когда вы создаете его удаленно, PowerShell открывает локальный сеанс на удаленном компьютере, который можно использовать для выполнения команд. Углубляться в технические подробности устройства сеанса нам не требуется. Достаточно знать, что вы можете создавать сеанс, подключаться и отключаться от него, и он будет сохранять последнее состояние, в котором вы его оставили. Сеанс не завершится, пока не будет удален. 

В предыдущем разделе, когда запускали командлет `Invoke-Command`, он начинал новый сеанс, выполнял код и сразу же завершал сеанс. 

Использование командлета `Invoke-Command` хорошо подходит для выполнения команд один раз, но не слишком эффективно, когда их много и они даже не помещаются в один блок сценария. Например, если вы работаете над большим сценарием для локальной работы и он должен получить информацию из другого источника, использовать ее в сеансе удаленного взаимодействия, а затем получить информацию из этого сеанса для локального использования и, наконец, снова вернуться на локальный компьютер, то вам нужно будет создать сценарий, который многократно запускает командлет `Invoke-Command`. Что еще хуже, у вас возникнут дополнительные проблемы, если вам нужно будет задать переменную в удаленном сеансе и использовать ее позже. Командлет `Invoke-Command`, который вы использовали до сих пор, уже не поможет — вам понадобится сеанс, который сохранится после вашего ухода.

### Создание нового сеанса 
Создать сеанс на удаленном компьютере через удаленное управление PowerShell, необходимо создать полный сеанс с помощью команды `New-PSSession` — она создаст сеанс на удаленном компьютере и будет ссылаться на него на локальном. 

```powershell
New-PSSession -ComputerName 250-prep
```

Команда `New-PSSession` возвращает сеанс. Когда сеанс будет задан, вы сможете входить и выходить из сеанса с помощью команды `InvokeCommand`, но вместо параметра `ComputerName` вам придется использовать параметр `Session`.

```powershell
Invoke-Command -Session $session -ScriptBlock {Get-Service}
```

В параметр `Session` нужно передать объект сеанса. Вы можете использовать команду `Get-PSSession`, чтобы вывести на экран все ваши текущие сеансы. 

```powershell
Get-PSSession
```

Поскольку команда `New-PSSession` запускалась всего один раз, то создастся всего один сеанс. Если у вас несколько сеансов, вы можете выбрать нужный для команды `Invoke-Command` с помощью параметра `Id` команды` Get-PSSession`.

```powershell
Invoke-Command -Session (Get-PSSession -Id 5)  -ScriptBlock {hostname}
```

> [!IMPORTANT]
> В этом примере все компьютеры находится в одном домене *Active Directory*. Чтобы подключиться с помощью параметра `ComputerName`, пользователь должен быть локальным администратором или, по крайней мере, входить в группу *«Пользователи удаленного управления»* на удаленном компьютере. Если вы не находитесь в домене *Active Directory*, то можете использовать параметр `Credential` команды `New-PSSession` для передачи объекта `PSCredential`. В этом объекте содержатся учетные данные для аутентификации на удаленном компьютере.

### Вызов команд в сеансе 
Теперь, когда ваш сеанс находится в переменной, вы можете передать ее в `Invoke-Command` и запустить какой-нибудь код внутри сеанса

```powershell
Invoke-Command -Session $session -ScriptBlock {Get-Service}
```

Эта команда выполняется намного быстрее, чем раньше, когда мы передавали ей другую команду. Все дело в том, что теперь `Invoke-Command` не приходится создавать и закрывать новый сеанс. Когда вы создаете сеанс, он не только работает быстрее, но и получает доступ к большему количеству функций. Например, вы можете задать переменные в удаленном сеансе, а затем вернуться в сеанс без потери этих переменных.

```powershell
Invoke-Command -Session $session -ScriptBlock { $foo = 'Please be here
 next time' }

Invoke-Command -Session $session -ScriptBlock { $foo }
```

Пока сеанс открыт, в удаленном сеансе можно делать все что угодно, и его состояние при этом не изменится. Но это действительно только для вашего текущего локального сеанса. Если вы запустите еще один процесс PowerShell, вы не сможете просто продолжить с того места, где остановились. Удаленный сеанс по-прежнему будет активен, но ссылка на этот удаленный сеанс на локальном компьютере исчезнет. В этом случае сеанс `PSSession` перейдет в отключенное состояние.

### Открытие интерактивных сеансов 
`Invoke-Command` используется для отправки команд на удаленный компьютер, он же и получает ответ. Выполнение таких удаленных команд похоже на выполнение неконтролируемого сценария. Этот вариант не такой интерактивный, как использование клавиш в консоли PowerShell. Если вы хотите открыть интерактивную консоль для сеанса, запущенного на удаленном компьютере, например для устранения неполадок, вы можете использовать команду `Enter-PSSession`. 

```powershell
 Enter-PSSession -ComputerName 250-prep
```

Команда `Enter-PSSession` позволяет пользователю работать с сеансом в интерактивном режиме. Команда может либо создать собственный сеанс, либо использовать существующий, созданный с помощью `New-PSSession`. Если вы не укажете сеанс, команда `Enter-PSSession` создаст новый и будет ждать дальнейшего ввода

```powershell
Enter-PSSession -Id 5
Enter-PSSession -Session $session 
```

Обратите внимание, что текст приглашения PowerShell изменился. Теперь команды будут выполняться в удаленном сеансе. На этом этапе вы можете запустить любую команду, как если бы вы находились в консоли удаленного компьютера. Такая интерактивная работа с сеансами — отличный способ отказаться от использования *Remote Desktop Protocol (RDP)* для вызова интерактивного интерфейса для выполнения таких задач, как устранение неполадок на удаленном компьютере.

### Отключение от сеансов и повторное подключение к ним 
Если вы закроете консоль PowerShell, снова откроете ее и попытаетесь использовать команду `Invoke-Command` в последнем рабочем сеансе, то получите сообщение об ошибке.

```powershell
$session = Get-PSSession -ComputerName websrv1
Invoke-Command -Session $session -ScriptBlock { $foo }
```

Если PowerShell находит сеанс `PSSession` на удаленном компьютере, но при этом не может найти ссылку на локальном, это означает, что сеанс отключен. Вот что происходит, если вы неправильно отключаете ссылку на локальный сеанс в удаленном `PSSession`. 

Вы можете отключить существующие сеансы с помощью команды `Disconnect-PSSession`. Можно очистить любые созданные ранее сеансы, если предварительно получить их с помощью команды `Get-PSSession`, а затем направить в команду `Disconnect-PSSession`. Как вариант, вы можете использовать параметр в `Disconnect-PSSession` для отключения одного сеанса за раз.

```powershell
Get-PSSession | Disconnect-PSSession
```

Чтобы правильно отключиться от сеанса, нужно передать имя удаленного компьютера в параметр `Session`. Это можно сделать либо вызовом его через объект сессии `Disconnect-PSSession -Session`, либо подтягиванием существующего сеанса в команду через `Get-PSSession`.

Если позже вы захотите снова подключиться к сеансу, то уже после отключения с помощью `Disconnect-PSSession` закройте консоль PowerShell и воспользуйтесь командой `Connect-PSSession`. Обратите внимание, что в этом случае вы можете подключаться только к отключенным сеансам, которые уже были созданы с вашей учетной записи. При этом вы не увидите сеансы, созданные другими пользователями.

```powershell
Connect-PSSession -ComputerName websrv1
```

Теперь вы можете запускать код на удаленном компьютере, словно вы и не закрывали консоль. 

> [!WARNING]
> Если вы получаете сообщение об ошибке, возможно, все дело в несовпадающих версиях PowerShell. Отключенные сеансы работают, только если локальный компьютер и удаленный сервер работают на **одинаковых версиях**. Например, если на локальном компьютере установлена *PowerShell 5.1*, а на удаленном стоит версия, которая не поддерживает отключенные сеансы (например, *PowerShell v2* или более ранняя), то ничего не выйдет. Нужно убедиться, что на локальном компьютере и на удаленном сервере установлена одна и та же версия PowerShell.

### Удаление сеансов с помощью команды Remove-PSSession 
Каждый раз, когда команда `New-PSSession` создает новый сеанс, он существует как на удаленном сервере, так и на локальном компьютере. Вы также можете одновременно открыть несколько сеансов на разных серверах. При этом если часть из этих сеансов больше не используется, вы, вероятно, захотите их удалить. Это можно сделать с помощью команды `Remove-PSSession`, которая прерывает сеанс на стороннем компьютере и удаляет ссылку на локальный сеанс `PSSession`, если он есть.

```powershell
Get-PSSession | Remove-PSSession
Get-PSSession
```

В этом примере мы снова запустили `Get-PSSession`, но ничего не получили. Это означает, что на вашем локальном компьютере нет активных сеансов.

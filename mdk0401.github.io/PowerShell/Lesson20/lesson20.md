# Урок 20. Функции в PowerShell

[На главную](/mdk0401.github.io)

До настоящего момента мы работали преимущественно со стандартными скомпилированными командлетами, функциональность которых нельзя изменить, так как их исходный код в оболочке `PowerShell` недоступен. **Функции и сценарии** — это два других типа команд `PowerShell`, которые можно создавать и изменять по своему усмотрению, пользуясь языком `PowerShell`. 

> [!NOTE] 
> Следует сразу обратить внимание, что функции в `PowerShell` **имеют некоторые особенности** по сравнению с функциями в традиционных языках программирования, так как `PowerShell` — это в первую очередь оболочка. 

`PowerShell` **функция — это команда**. Отсюда различие в способах вызова функций и передачи им аргументов. Обычно функции в традиционных языках возвращают единственное значение того или иного типа. *"Значением"* функции `PowerShell` может быть целый массив различных объектов, так как каждое вычисляемое в функции выражение помещает свой результат в выходной поток. Кроме того, функции в `PowerShell` делятся на несколько типов согласно их поведению внутри конвейера команд. 

**Функция** в `PowerShell` — это блок кода, имеющий название и находящийся в памяти до завершения текущего сеанса командной оболочки.

```powershell
function Verb-Noun {
   # code
}
```

Если функция определяется без формальных параметров, то для ее задания достаточно указать ключевое слово `Function`, затем имя функции и список выражений,  составляющих тело функции (данный список должен быть заключен в фигурные скобки).

```powershell
function Get-MyPSVersion {
    $PSVersionTable.PSVersion
}
```

После загрузки в память её можно найти

```powershell
Get-Command -CommandType Function

Get-PSDrive
Get-ChildItem Function:\Get-MyPSVersion
```

## Именование
Имена функций — важная деталь. Функцию  можно назвать как угодно, но имя всегда должно описывать то, что она делает. Соглашение об именах функций в `PowerShell` следует синтаксису *«глагол-существительное»*. 

Считается, что лучше всегда использовать этот синтаксис, если в другом нет острой необходимости. Можно использовать команду `Get-Verb`, чтобы просмотреть список рекомендуемых глаголов. В качестве существительного обычно выступает имя объекта, с которым работают, в единственном числе 

```powershell
Get-Verb
```

## Обработка аргументов функций с помощью переменной $Args 
Функция в `PowerShell` имеет доступ к аргументам, с которыми она была запущена, даже если при определении этой функции не были заданы формальные параметры. Все аргументы, с которыми была запущена функция, автоматически сохраняются в переменной `$Args`. Другими словами, в переменной `$Args` содержится массив, элементами которого являются параметры функции, указанные при ее запуске. 

```powershell
function Get-LastLog {
    Get-EventLog -LogName Application | Where-Object { $_.TimeWritten -ge (Get-Date).AddDays(-1) }
}

Get-LastLog
```

Учитывая, что может потребоваться получить данные не за последний час, а больше, то лучше передавать параметры.

```powershell
function Get-LastLog {
    $h = -$args[0]

    Get-EventLog -LogName Application | Where-Object { $_.TimeWritten -ge (Get-Date).AddHours($h) }
}

Get-LastLog 62
```

В отличие от традиционных языков программирования, функции в `PowerShell` являются командами (это не методы объектов!), поэтому их аргументы указываются через пробел без дополнительных круглых скобок и выделения символьных строк кавычками. 

```powershell
function Print-Args {
    Write-Host "Передано аргументов:" $args.count
    Write-Host "Аргумент 0:" $args[0]
    Write-Host "Аргумент 1:" $args[1] 
    Write-Host "Аргумент 2:" $args[2]
}


Print-Args Ноль Один 123
```

Описанный выше способ позволяет передать в сценарий или функцию любое количество параметров, но при вызове необходимо соблюдать порядок их следования, а обращаться к ним можно только по индексу массива — это не всегда удобно.

## Формальные параметры функций
В `PowerShell`, как и в большинстве других языков программирования, при описании функции можно задать список формальных параметров, значения которых во время выполнения функции будут заменены значениями фактически переданных аргументов. Список формальных параметров указывается в круглых скобках после имени функции. 

```powershell
function Get-LastLog($n, $h) {
    $h *= -1

    Get-EventLog -LogName Application -Newest $n | Where-Object { $_.TimeWritten -ge (Get-Date).AddHours($h) }
}

Get-LastLog 100 24
```

При вызове функции ее формальные параметры будут заменены фактическими аргументами, определяемыми либо по позиции в командной строке, либо по имени.

В этом случае соответствие формальных параметров фактически переданным аргументам определяется по позиции: вместо первого параметра *$n* подставляется число *100*, вместо второго параметра *$h* подставляется число *24*. 

При указании аргументов можно использовать имена формальных параметров (порядок указания аргументов при этом становится несущественным)

```powershell
Get-LastLog -h 24 -n 100
Get-LastLog -n 100 -h 24 
```

При вызове функции возможен и третий вариант задания аргументов, когда для некоторых задаются имена, а некоторые определяются по позиции в командной строке. При этом действует следующий алгоритм: **Все именованные аргументы сопоставляются соответствующим формальным параметрам и удаляются из списка аргументов. Оставшиеся параметры (безымянные или имеющие имя, которому не соответствует ни один формальный параметр) сопоставляются формальным параметрам по позиции.**

```powershell
Get-LastLog -h 24 5
```

> [!WARNING]
> Без необходимости при вызове функций не следует смешивать именованные и *"позиционные"* аргументы — это поможет избежать возможных ошибок при сопоставлении формальных и фактических параметров


## Типы параметров
По умолчанию функции `PowerShell`, как и другие команды, ведут себя полиморфным образом

```powershell
function Add-Num($num1, $num2) {
    $num1 + $num2
}

(Add-Num 23 45).GetType()

(Add-Num "a" "bc").GetType()
```

При объявлении функции можно явно задать тип формальных параметров.

```powershell
function Add-Num([int]$num1, [int]$num2) {
    $num1 + $num2
}
```

## Установка значений по умолчанию
При объявлении формальных параметров можно указать значения, которые будут принимать эти параметры по умолчанию (если явно не указан соответствующий фактический аргумент)

```powershell
function Get-LastLog($n = 100, $h) {
    $h *= -1

    Get-EventLog -LogName Application -Newest $n | Where-Object { $_.TimeWritten -ge (Get-Date).AddHours($h) }
}

Get-LastLog -h 12
Get-LastLog 12          # error
```

Для правильной работы необходимо поменять местами список параметров в функции

```powershell
function Get-LastLog($h, $n = 100) {
    ....
```

> [!IMPORTANT]
> При вызове функции может быть указано большее количество фактических аргументов, чем было задано формальных параметров. При этом *"лишние"* аргументы будут помещены в массив `$Args`. 

## Возвращаемые значения 
В традиционных языках программирования функция обычно возвращает единственное значение определенного типа. В оболочке `PowerShell` дело обстоит иначе — здесь результаты всех выражений или конвейеров, вычисляемые внутри функции, направляются в выходной поток.

```powershell
function Show-Result {
    $num = 345
    2+2
    echo "Hello world"
    # Write-Host $num
}


$res = Show-Result

# Write-Host $res
# $res.GetType()
```

Командлет `Write-Host` выводит строку непосредственно на консоль, а не в выходной поток.

В языке `PowerShell` имеется инструкция `Return`, выполняющая немедленный выход из функции

```powershell
function Use-Return ([int] $R){
    return [System.Math]::PI * $R*$R
}

Use-Return 5
```

> [!IMPORTANT]
> Инструкция `Return` включена в язык `PowerShell` скорее как дань традиции, так как аналогичные операторы есть практически во всех языках программирования. Однако следует помнить, что `PowerShell` является оболочкой, и имеет смысл говорить не о единственном значении, возвращаемом функцией, а о выходном потоке, в который функция помещает результаты вычисления выражений.

Возвращаемых значений может быть несколько. По умолчанию всегда возвращается массив. 

```powershell
# PowerShell 7.0 introduced a new syntax using the ternary operator.
# 
function Get-MaxMinAvg ($n1, $n2) {
    if ($n1 -lt $n2) {
        $min = $n1
        $max = $n2
    } elseif ($n1 -eq $n2) {
        $min = $max = $n1
    } else {
        $min = $n2
        $max = $n1
    }

    $avg = ($n1 + $n2) / 2

    return $max, $min, $avg    
}

$result = Get-MaxMinAvg 75 25
Write-Host $result
```

В данном примере так же возвращается массив

```powershell
function Get-HeavyProcess {
   Get-Process | Sort-Object WS -Descending | Select-Object -First 5 
}

$p = Get-HeavyProcess
$p[1]
```
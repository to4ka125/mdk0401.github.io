# Урок 25. Управление процессами и службами

[На главную](/mdk0401.github.io)

## Описание технологии COM
Для инструментальных систем и систем управления, реализованных на платформе Windows, фирмой Microsoft предложена **архитектура компонентных объектов**.

**COM** (*Component Object Model* – модель компонентных объектов) - это спецификация метода создания компонентов и построения из них приложений. 

**Компонент** – это готовый к использованию **двоичный код**, содержащийся либо в динамической библиотеке (*DLL*), либо в *EXE-файле*, который может быть при необходимости загружен в память и стандартным образом динамически подключен к приложению. 

Две основные черты компонентов:

- динамическое связывание – означает, что связь компонента и приложения (т.е. связь между вызовом функции в приложении и ее кодом в теле компонента) осуществляется не на этапе компоновки приложения, а **непосредственно во время его выполнения**;

- скрытая внутренняя реализация (инкапсуляция) – означает, что для приложения не важно, и приложение не знает, как именно реализован компонент внутри, а только **знает, как вызывать его функции**.

Традиционно приложение состояло из отдельных файлов, модулей или классов, которые компилировались и компоновались вместе. Разработка приложений из компонентов - так называемых приложений компонентной архитектуры - происходит иначе. Компонент подобен мини-приложению, он поставляется пользователю как двоичный код, скомпилированный, скомпонованный и готовый к использованию. Модификация или расширение приложения сводится к замене одного из составляющих его компонентов новой версией.

Один из наиболее многообещающих аспектов компонентной архитектуры - это быстрая разработка и развитие приложений. Из накапливаемого набора компонентов в библиотеках можно будет собирать, как из деталей конструктора, требуемые цельные приложения.

Компонент подключается к приложению через **интерфейс**, единый для приложения и компонента. Отметим, что, для того, чтобы подключить к приложению компонент, важно знать, какой интерфейс он использует.

Интерфейс COM включает в себя набор функций, которые реализуются компонентами и используются клиентами. Интерфейсом в COM является определенная структура в памяти, содержащая массив указателей на функции.

Таким образом, COM - это спецификация, указывающая, как создавать динамически взаимозаменяемые компоненты. COM определяет стандарт, которому должны следовать компоненты и клиенты, чтобы гарантировать возможность совместной работы. Компоненты COM состоят из исполняемого кода, распространяемого в виде динамически компонуемых библиотек (*DLL*) или *EXE-файлов*. Но сама по себе динамическая компоновка не обеспечивает компонентной архитектуры. Компоненты COM объявляют о своем присутствии стандартным способом. Используя схему объявлений COM, клиенты могут динамически находить нужные компоненты. Отметим, что реализация этой возможности возложена на операционную систему.

## Работа с COM-объектами
В настоящее время COM-объекты по-прежнему широко используются в Windows. Многие приложения как компании Microsoft (Microsoft Office, Internet Explorer, Internet Information Service (IIS) и т. д.), так и сторонних разработчиков являются серверами автоматизации, предоставляя через COM-объекты доступ к своим службам. 

Работая в PowerShell, мы будем идентифицировать COM-объекты по их программным идентификаторам (*ProgID*) — символьным псевдонимам, назначаемым при регистрации объектов в системе. Согласно общепринятому соглашению идентификаторы *ProgID* имеют следующий вид (при этом общая длина программного идентификатора не должна превышать 39 символов)

```
Библиотека_типов.Класс.Версия

Библиотека_типов.Класс
```

Перед первой точкой в *ProgID* стоит имя библиотеки типов (*type library*) для объекта, которая может существовать как в виде отдельного файла с расширением *tlb*, так и в виде части файла с исполняемым кодом объекта. Библиотека типов, содержащая сведения о COM-объекте, регистрируется в системном реестре при установке приложения, публикующего этот объект. Довольно часто имя библиотеки типов совпадает с именем приложения, являющегося сервером COM-объектов. После точки в *ProgID* указывается имя класса, содержащего свойства и методы COM-объекта, доступные для использования другими приложениями.

Вот несколько примеров *ProgID*: **InternetExplorer.Application** (приложение Internet Explorer), **Word.Application** (приложение Microsoft Word), **WScript.Shell** (класс Shell из объектной мо- дели сервера сценариев Windows Script Host)

В PowerShell имеется командлет `New-Object`, позволяющий, в частности, создавать экземпляры внешних COM-объектов, указывая соответствующий *ProgID* в качестве значения параметра `-ComObject`.

```powershell
$sh = New-Object -ComObject Wscript.shell
```

## Пример использования
[![Использование COM в PowerShell](https://img.youtube.com/vi/rzOEznmjvMk/0.jpg)](https://www.youtube.com/watch?v=rzOEznmjvMk)



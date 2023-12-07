# Урок 04. Подстановка параметров. Строки
[На главную](/mdk0401.github.io)

## Команда echo
Команда echo - это не системная утилита, у нее нет исполняемого файла. Она существует только внутри интерпретатора Bash. 

Опции команда ```echo```:

    -n - не выводить перевод строки;
    -e - включить поддержку вывода Escape последовательностей;
    -E - отключить интерпретацию Escape последовательностей.

Если включена опция ```-e```, то вы можете использовать следующие *Escape последовательности* для вставки специальных символов:

    \NNN - символ с ASCII кодом NNN (восьмеричное) 
    \a - тревога (BEL) 
    \c - удалить перевод строки;
    \t - горизонтальная табуляция;
    \v - вертикальная табуляция;
    \b - удалить предыдущий символ;
    \n - перевод строки;
    \r - символ возврата каретки в начало строки.

```bash
echo -e "\tHello, world\n!!"  # ключ -e в команде echo включает отображение "backslash escapes"; например \n - переход на следующую строку, \t -табуляция

echo -e "\aСигнал"

echo -n "Текст сообщения"   # ключ -n в команде echo сигнализирует, что после вывода информации не нужно переходить на следующую строку.

echo -en "Текст сообщения"  # в нашем случае поможет раскрасить вывод текста.
```

Вы можете изменить вывод ```echo``` с помощью последовательностей управления цветом Bash. Доступны следующие цвета для текста:

+ \033[30m - чёрный;
+ \033[31m - красный;
+ \033[32m - зелёный;
+ \033[33m - желтый;
+ \033[34m - синий;
+ \033[35m - фиолетовый;
+ \033[36m - голубой;
+ \033[37m - серый.

И цвет фона:

+ \033[40m - чёрный;
+ \033[41m - красный;
+ \033[42m - зелёный;
+ \033[43m - желтый;
+ \033[44m - синий;
+ \033[45m - фиолетовый;
+ \033[46m - голубой;
+ \033[47m - серый;
+ \033[0m - сбросить все до значений по умолчанию.

Например. раскрасим нашу надпись в разные цвета:

```
echo -e "\e[COLORm Sample Text \e[0m"   # \e = \033 code ESC
```

```bash
echo -e "\e[36m Sample Text \e[0m"
```

|Цвет|Foreground Code|Background Code|HEX|
| :--: | :--: | :--: | :--:|
|Black| 	30| 	40| `#000000` |
|Red| 	31| 	41| `#FF0000`| 	
|Green| 	32| 	42| `#008000`	|
|Brown| 	33| 	43| `#A52A2A`	|
|Blue| 	34| 	44| `#0000FF`	|
|Purple| 	35| 	45| `#800080`	|
|Cyan| 	36| 	46| `#00FFFF`	|
|Light Gray| 	37| 	47| `#D3D3D3`	|

```bash
echo -e "\033[35mLinux \033[34mopen \033[32msource \033[33msoftware \033[31mtechnologies\033[0m"

echo -e "\e[35mLinux \e[34mopen \e[32msource \e[33msoftware \e[31mtechnologies\e[0m"
```

Допускается объединение этих управляющих последовательностей. Вывод цветного текста осуществляется по следующему шаблону:

```bash
echo -e "\E[COLOR1;COLOR2mКакой либо текст."
```

Где ```\e[``` - начало *escape-последовательности*. Числа "COLOR1" и "COLOR2", разделенные точкой с запятой, задают цвет символов и цвет фона, в соответствии с таблицей цветов, приведенной ниже. (Порядок указания цвета текста и фона не имеет значения, поскольку диапазоны числовых значений цвета для текста и фона не пересекаются). 

> [!IMPORTANT]
> Символ ```m``` - должен завершать *escape-последовательность*.

```bash
echo -e "\e[43;35mИС-21 привет\e[0m"
```

*escape-последовательности* также позволяет управлять способом отображения символов на экране:

|ANSI код| Описание|
| :--: | :--: |
|0| 	по умолчанию|
|1| 	жирный шрифт (интенсивный цвет)|
|4| 	подчеркивание|
|7| 	реверсия (знаки приобретают цвет фона, а фон - цвет знаков)|

```bash
echo -e "\e[1mBold Text\e[0m"       # bold

echo -e "\e[3mUnderlined Text\e[0m" #underline
```

### Пример
Чужой пример, но очень хорошо показывает как можно использовать *escape-последовательности*

```bash
#!/bin/sh

# Дополнительные свойства для текта:
BOLD='\033[1m'       #  ${BOLD}      # жирный шрифт (интенсивный цвет)
DBOLD='\033[2m'      #  ${DBOLD}    # полу яркий цвет (тёмно-серый, независимо от цвета)
NBOLD='\033[22m'      #  ${NBOLD}    # установить нормальную интенсивность
UNDERLINE='\033[4m'     #  ${UNDERLINE}  # подчеркивание
NUNDERLINE='\033[4m'     #  ${NUNDERLINE}  # отменить подчеркивание
BLINK='\033[5m'       #  ${BLINK}    # мигающий
NBLINK='\033[5m'       #  ${NBLINK}    # отменить мигание
INVERSE='\033[7m'     #  ${INVERSE}    # реверсия (знаки приобретают цвет фона, а фон -- цвет знаков)
NINVERSE='\033[7m'     #  ${NINVERSE}    # отменить реверсию
BREAK='\033[m'       #  ${BREAK}    # все атрибуты по умолчанию
NORMAL='\033[0m'      #  ${NORMAL}    # все атрибуты по умолчанию

# Цвет текста:
BLACK='\033[0;30m'     #  ${BLACK}    # чёрный цвет знаков
RED='\033[0;31m'       #  ${RED}      # красный цвет знаков
GREEN='\033[0;32m'     #  ${GREEN}    # зелёный цвет знаков
YELLOW='\033[0;33m'     #  ${YELLOW}    # желтый цвет знаков
BLUE='\033[0;34m'       #  ${BLUE}      # синий цвет знаков
MAGENTA='\033[0;35m'     #  ${MAGENTA}    # фиолетовый цвет знаков
CYAN='\033[0;36m'       #  ${CYAN}      # цвет морской волны знаков
GRAY='\033[0;37m'       #  ${GRAY}      # серый цвет знаков

# Цветом текста (жирным) (bold) :
DEF='\033[0;39m'       #  ${DEF}
DGRAY='\033[1;30m'     #  ${DGRAY}
LRED='\033[1;31m'       #  ${LRED}
LGREEN='\033[1;32m'     #  ${LGREEN}
LYELLOW='\033[1;33m'     #  ${LYELLOW}
LBLUE='\033[1;34m'     #  ${LBLUE}
LMAGENTA='\033[1;35m'   #  ${LMAGENTA}
LCYAN='\033[1;36m'     #  ${LCYAN}
WHITE='\033[1;37m'     #  ${WHITE}

# Цвет фона
BGBLACK='\033[40m'     #  ${BGBLACK}
BGRED='\033[41m'       #  ${BGRED}
BGGREEN='\033[42m'     #  ${BGGREEN}
BGBROWN='\033[43m'     #  ${BGBROWN}
BGBLUE='\033[44m'     #  ${BGBLUE}
BGMAGENTA='\033[45m'     #  ${BGMAGENTA}
BGCYAN='\033[46m'     #  ${BGCYAN}
BGGRAY='\033[47m'     #  ${BGGRAY}
BGDEF='\033[49m'      #  ${BGDEF}

#Начало меню
echo ""
echo -n "     "
echo -e "${BOLD}${BGMAGENTA}${LGREEN} Меню DNS323 ${NORMAL}"
echo ""
echo -en "${LYELLOW} 1 ${LGREEN} Комманды для удобной работы в telnet ${GRAY}(Выполнить?)${NORMAL}\n" 
echo ""
echo -en "${LYELLOW} 2 ${LGREEN} Пути к папкам & Изменение прав доступа ${GRAY}(Комманды)${NORMAL}\n" 
echo ""
echo -en "${LYELLOW} 3 ${LGREEN} Transmission (${GREEN}Start${NORMAL}, ${LRED}Stop${NORMAL}, ${CYAN}Upgrade${NORMAL}) ${GRAY}(Меню)${NORMAL}\n" 
echo ""
echo -en "${LYELLOW} 4 ${LGREEN} Копирование (cp & rsync) ${GRAY}(Комманды)${NORMAL}\n"
echo ""
echo -en "${LYELLOW} 5 ${LGREEN} Создание ссылки на файл или папку ${GRAY}(Комманды)${NORMAL}\n"
echo ""
echo -en "${LYELLOW} 6 ${LGREEN} Установка из fun-plug & IPKG ${GRAY}(Комманды)${NORMAL}\n"
echo ""
echo -en "${LYELLOW} 7 ${LGREEN} Показать Трафик (${LYELLOW} n${LGREEN}load) ${GRAY}(Выполнить?)${NORMAL}\n"
echo ""
echo -en "${LYELLOW} 8 ${LGREEN} Диспетчер задач (${LYELLOW} h${LGREEN}top) ${GRAY}(Выполнить?)${NORMAL}\n"
echo ""
echo -en "${LYELLOW} 9 ${LGREEN} Midnight Commander (${LYELLOW} m${LGREEN}c) ${GRAY}(Выполнить?)${NORMAL}\n"
echo ""
echo -en "${LMAGENTA} q ${LGREEN} Выход ${NORMAL}\n"
echo ""
echo "(Введите пожалуйта номер пункта, чтобы выполнить комманды этого пункта, любой другой ввод, Выход)"
echo ""
```

## Подстановка параметров
**Простой подстановкой (expansion)** называется замена обращения к переменной ее значением. Простые подстановки это что-то похожее на обращение к переменной в других языках программирования, но в Bash эта операция отличается следующим:

1. Заменяемая переменная может быть не объявлена: в этом случае мы говорим, что подстановка раскрывается в пустоту. Пустота есть пустота: место в сценарии, в котором прописано раскрытие останется пустым, как будто само раскрытие не было записано в коде сценария.

1. Переменная может быть объявлена, но проинициализирована пустотой. Следует отличать понятия пустоты и пустой строки (т.е. строки с нулевым числом символов): пустая строка в отличие от пустоты может быть проверена на длину; над пустой строкой можно выполнять строковые операции, а над пустотой нельзя.

У простой подстановки есть две формы:

1. **Упрощенная**. В упрощенной форме достаточно после знака доллара написать имя переменной, например ```$VARIABLE_NAME```.

1. **Строгая**. В строгой форме имя переменной нужно поместить в фигурные скобки, например ```${VARIABLE_NAME}```. В таком виде строгая форма ничем не отличается от упрощенной, тем не менее только строгая форма разрешает **вам пользоваться встроенными подстановочными операциями** — мощным инструментом командной оболочки. Строгая форма, помимо всего прочего, определяет где заканчивается имя подставляемой переменной, так как его границы определены фигурными скобками. 

```bash
VAR="Good "
VAR_="Bad "

# Значение какой переменной будет подставлено?
echo "$VAR_day"

# В данном случае никакой из существующих (пустая подстановка). Интерпретатор будет пытаться искать
# переменную VAR_day, которая не определена.
# Чтобы разрешить неоднозначтность, нужно использовать строгую форму, чтобы обозначить границы имени переменной

echo "${VAR}day" # "Good day"
echo "${VAR_}day" # "Bad day"
```

**Подстановочные операции** (Shell Parameter Expansion) позволяют преобразовать значение переменной перед подстановкой, при этом не перезаписывая оригинальное значение. 

### Операции, связанные с присваиванием

#### \${parameter-default}, \${parameter:-default}
```bash
echo ${EMPTYNESS-"NULL"} # Если переменная EMPTYNESS раскрывается в пустоту, то вместо нее будет подставлено значение справа от тире.
                        # Результат: "NULL"
EMPTYNESS=""
echo ${EMPTYNESS:-"EMPTY"} # Если переменная EMPTYNESS раскрывается в пустоту или в строку нулевой длины,
                      # то вместо нее будет подставлено значение справа от :-.
                      # Результат: "EMPTY"

```

#### \${parameter=default}, \${parameter:=default}
> [!IMPORTANT]
> В отличии от предыдущей подстановки, данная присваивает значение переменной.

```bash
echo ${EMPTYNESS="DEFAULT_VALUE"}   # Если переменная EMPTYNESS раскрывается в пустоту, то вместо нее будет подставлено и ПРИСВОЕНО значение справа от равно.
echo "Result = $EMPTYNESS"          # Результат: "DEFAULT_VALUE"    

EMPTYNESS=""
echo ${EMPTYNESS:="qqqqq"}  # Если переменная EMPTYNESS раскрывается в пустоту или в строку нулевой длины,
                            # то вместо нее будет подставлено и ПРИСВОЕНО значение справа от равно.
                            # Результат: "DEFAULT_VALUE"
```

#### \${parameter+alt_value}, \${parameter:+alt_value}

Если переменная не раскрывается в пустоту, то будет подставлена строка справа от ```+```
```bash
a=${param1+xyz}     # получаем раскрытие в пустоту и подставляем ЛЕВУЮ часть
echo "a = $a"       # a =

param2=
a=${param2+xyz}
echo "a = $a"      # a = xyz

param3=123
a=${param3+xyz}
echo "a = $a"      # a = xyz
```

Если переменная не раскрывается в пустоту, либо в строку нулевой длины, то будет подставлена строка справа от ```:+```.

```bash
a=${param4:+xyz}
echo "a = $a"      # a =

param5=            # пустая строка
a=${param5:+xyz}
echo "a = $a"      # a =
# Вывод отличается от a=${param5+xyz}

param6=123
a=${param6+xyz}
echo "a = $a"      # a = xyz
```

#### \${parameter?err_msg}, \${parameter:?err_msg}
Следующие две подстановочные операции используются обычно для технологических проверок инициализации переменных.

```bash
: ${EMPTYNESS?"is NULL"} # Сценарий будет аварийно прерван с сообщением, указанным после знака вопроса, если переменная раскрывается в пустоту.

: ${EMPTYNESS:?"is NULL or string empty"} # Сценарий будет аварийно прерван с сообщением, указанным после :?, если переменная раскрывается в пустоту или в строку нулевой длины.
```

### Работа с регистром символов

```bash
TEST_STR="sOmE_Text@123"
echo "(Original test)" ${TEST_STR}

echo "(To upper case)" ${TEST_STR^^}                     # Перевести все символы в верхний регистр
echo "(To upper case for first letter)" ${TEST_STR^}     # Перевести в верхний регистр только первый символ строки

STR_TO_LOWER=${TEST_STR^^}
echo "(To lower case)" ${TEST_STR,,}                     # Перевести все символы в нижний регистр
echo "(To lower case for first letter)" ${STR_TO_LOWER,}   # Перевести в нижний регистр только первый символ

echo "(Reverse case for every letter)" ${TEST_STR~~}     # Инвертировать регистр каждого символа в строке
echo "(Reverse case for first letter)" ${TEST_STR~}      # Инвертировать регистр только первого символа
```

### Работа со строками и выделение подстрок

```bash
echo "Number of letters in TEST_STR: ${#TEST_STR}" # Возвращает число символов в строке
echo "Substring (from 0 symbol get 5 symbols): ${TEST_STR:0:5}" # Выделяет подстроку из 5 символов, начиная с символа с индексом 0 (т.е. с первого)
echo "Display string from 4th symbol: ${TEST_STR:3}" # Выделяет подстроку, начиная с символа с индексом 3

# Вы можете использовать отрицательные числа, чтобы проходить строку с правого края.
echo "Cut off 3 symbols from right edge: ${TEST_STR:0:-3}" # Отсечь три символа справа

# В следующем примере мы захватываем три последних символа через отступ на три
# символа от правого края. Обратите внимание, что пробел перед минусом обязательный.
echo "Display last 3 symbols: ${TEST_STR: -3:3}"  # Первый способ
echo "Display last 3 symbols: ${TEST_STR:(-3):3}" # Второй способ
```

### Замена подстрок

```bash
TEST_STR="Very long long string with spaces."
echo "(Original string) $TEST_STR"

echo "(Replace 'long' by 'short') ${TEST_STR//long/short}"  # Заменить все вхождения 'long' на 'short'
echo "(Replace 'long' by 'short') ${TEST_STR/long/short}"   # Заменить только первое вхождение 'long' на 'short'
echo "(Remove 'long' from the text) ${TEST_STR//long }"     # Удалить все вхождения 'long'. Фактически мы заменяем их строкой нулевой длины
echo "(Remove 'long' from the text) ${TEST_STR/long }"      # Удалить только первое вхождение 'long'
```

## Скобочные подстановки
**Скобочные подстановки** (Brace Expansion) обычно используются для генерации списков, в которых есть комбинаторные закономерности. Обычно это полезно в циклах ```for``` и при заполнении массивов некоторыми данными.

> [!NOTE]
> Скобочная подстановка так называется потому, что она оформляется через фигурные скобки.

```
{0..5} # "0 1 2 3 4 5"
{00..05} # "00 01 02 03 04 05"
{a..z} # Список из всех букв латинского алфавита
1.{0..5} # "1.0 1.1 1.2 1.3 1.4 1.5"
{0..20..2} # Можно генерировать ряд чисел с шагом "0 2 4 6 8 ... 20"
{0000..20..2} # "0000 0002 0004 ... 0020"

# Скобочные подстановки можно вкладывать
{ {A..Z},{a..z},{0..9} } # "A B ... Z a b ... z 0 1 ... 9"

# Комбинаторный пример: генерация имен файлов
{john,bill}{0..3}.tar.{bz2,gz}
# john0.tar.bz2
# john0.tar.gz
# john1.tar.bz2
# john1.tar.gz
# ....
# bill0.tar.bz2
# bill0.tar.gz
# ....
# bill3.tar.gz
```
# Класика и джаз

Представете си, че имаме каталог с музиката, която слушаме. Искаме да му задаваме въпроси от рода на:

* Дай ми всички песни на този изпълнител.
* Дай ми всички меланхолични джаз песни.
* Дай ми всички песни, които имат буквата “е”.
* Дай ми всички песни, в които има саксофон.

Всяка песен в нашия каталог има следните неща:

* name – Име (`"My Favourite Things"`)
* artist – Изпълнител или композитор (`"John Coltrane"`)
* genre – Жанр (`"Jazz"`)
* subgenre – Опционален поджанр: (`"Bebop"`)
* tags – Етикети (множество от низове `%w[saxophone popular jazz bebop cover]`)

Песните са записани в текстов низ със следния формат:

<pre class="plain">My Favourite Things.          John Coltrane.      Jazz, Bebop.        popular, cover
Greensleves.                  John Coltrane.      Jazz, Bebop.        popular, cover
Alabama.                      John Coltrane.      Jazz, Avantgarde.   melancholic
Acknowledgement.              John Coltrane.      Jazz, Avantgarde
Afro Blue.                    John Coltrane.      Jazz.               melancholic
'Round Midnight.              John Coltrane.      Jazz
My Funny Valentine.           Miles Davis.        Jazz.               popular
Tutu.                         Miles Davis.        Jazz, Fusion.       weird, cool
Miles Runs the Voodoo Down.   Miles Davis.        Jazz, Fusion.       weird
Boplicity.                    Miles Davis.        Jazz, Bebop
Autumn Leaves.                Bill Evans.         Jazz.               popular
Waltz for Debbie.             Bill Evans.         Jazz
'Round Midnight.              Thelonious Monk.    Jazz, Bebop
Ruby, My Dear.                Thelonious Monk.    Jazz.               saxophone
Fur Elise.                    Beethoven.          Classical.          popular
Moonlight Sonata.             Beethoven.          Classical.          popular
Pathetique.                   Beethoven.          Classical
Toccata e Fuga.               Bach.               Classical, Baroque. popular
Goldberg Variations.          Bach.               Classical, Baroque
Eine Kleine Nachtmusik.       Mozart.             Classical.          popular, violin
</pre>

* По една песен на ред
* Стойностите са разделени с точка (.)
* Може да има повторения, както в имена на песни, така и на артисти
* Жанрът и поджанрът са в едно поле, като вторият е опционален. Ако го има, разделени са със запетая.
* Последното поле е списък от етикети, разделени със запетаи. Може да е празно.
* Освен от изрично изброените, една песен може да получава етикети от две други места – артист и жанрове.

Знаем, че всички песни на Колтрейн имат саксофон, а пък Бах пише полифонична музика за пиано. Затова, освен този текстов низ, имаме и следния речник:

    {
      'John Coltrane' => %w[saxophone],
      'Bach' => %w[piano polyphony],
    }

Горното казва, че всички песни на Колтрейн трябва да имат етикет `saxophone`, а всички на Бах – етикети `piano` и `polyphony`.

Жанрът и поджанрът трябва също да дават етикети. Ако една песен е “Jazz, Bebop”, тя трябва да получи етикетите `jazz` и `bebop` (изцяло малки букви). Ако е само “Jazz”, получава само един етикет – `jazz`.

## Идеята

Първо трябва да създадете обекти, които представят песен. Няма значение от какъв клас са, стига да имат следните методи:

    # My Favourite Things;    John Coltrane;      Jazz, Bebop;        popular
    song.name     # "My Favourite Things"
    song.artist   # "John Coltrane"
    song.genre    # "Jazz"
    song.subgenre # "Bebop"
    song.tags     # ['popular', 'jazz', 'bebop', 'saxophone']

    # Eine Kleine Nachtmusik; W.A. Mozart;        Classical;          popular
    song.name     # "Eine Kleine Nachtmusik"
    song.artist   # "W.A. Mozart"
    song.genre    # "Classical"
    song.subgenre # nil
    song.tags     # ['classical', 'popular']

Трябва да дефинирате клас, представящ музикалната колекция:

    collection = Collection.new(songs_as_string, artist_tags)

`songs_as_string` е текстовият низ с песни, чийто формат описахме по-горе.

Колекциите трябва да дефинират метод `find`:

    class Collection
      def find(criteria)
        ...
      end
    end

Няколко примера как трябва да работи find:

    # Намира всички песни с етикет jazz:
    collection.find tags: 'jazz'

    # Намира всички песни, които имат двата етикета jazz и piano:
    collection.find tags: %w[jazz piano]

    # Намира всички песни, които имат етикет jazz и нямат етикет piano:
    collection.find tags: %w[jazz piano!]

    # Намира всички популярни песни на Джон Колтрейн:
    collection.find tags: 'popular', artist: 'John Coltrane'

    # Връща имена на песни, които започват с думичката "My":
    collection.find filter: ->(song) { song.name.start_with?('My') }

## Спецификацията

Да се създаде клас `Collection`, който има:

* Конструктор, вземащ два аргумента
  * Първият е текстов низ, съдържащ каталог с песни в показания по-горе формат.
  * Вторият е речник, съпоставящ име на артист (низ) с етикети (списък от низове), които всички негови песни трябва да имат.
* Метод `find(criteria)`. `criteria` е хеш, чиито ключове и стойности дефинират кои песни да се търсят.
* `criteria[:tags]` – Съдържа низ или списък от низове. Ограничава резултатите до песни, притежаващи всички етикети. Ако някой етикет завършва на удивителна (!), ограничава песните до тези, които нямат този етикет. Очевидно, етикетите няма да съдържат удивителна в края на оригиналното си име, за да може този критерий да работи.
* `criteria[:name]` – Низ. Ограничава до песни, чието име съвпада с низа.
* `criteria[:artist]` – Аналогично на предното, но за име на изпълнител.
* `criteria[:filter]` – Ламбда, приемаща един аргумент, който е песен (с изброените горе методи) и връщаща булева стойност. `find` трябва да ограничи резултатите до песни, за които `criteria[:filter]` се оценява до истина.
* Обърнете внимание, че критериите са конюнктивни. Търсят се песни, които отговарят на всички.
* Може би е очевидно, но ако няма резултати, връщате празен списък. Ако има един резултат, връщате списък с един елемент.
* Редът на върнатите обекти няма значение.
* Ако `find` се извика с празен речник за `criteria`, връща всички песни (всички артисти, всички жанрове и т.н.).
* Няма никакво значение какво точно ще бъдат песните, стига да имат посочените пет атрибута.

## Подсказки

* В тази задача се правят две неща – парсене на вход и проверка дали песен отговоря на критерии. Подходящо е тези неща да са в два различни класа - парсенето в `Collection`, филтрирането в `Song`.
* Разгледайте какво правят `Array(1)`, `Array([1, 2])` и `String#lines`.
* Ако искате за всеки ред от входа да създадете песен, това става с `#map`. Ако искате да филтрирате песните по критерий, това става със `#select`.
* Избягвайте да имате дълги методи, в които стават много неща. В едно хубаво решение, всеки от класовете може да има по 5-6 метода. Ако сте дефинирали само два конструктура и един `#find`, правите нещо грешно.

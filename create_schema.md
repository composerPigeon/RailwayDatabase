# Databázová aplikace pro správu železnic

## Zadání práce
Jako zadání jsem si vybral databázovou aplikaci pro správu železniční infrastruktury. Aplikace tedy hlavně eviduje vlaky a jejich polohu. Dále umožňuje správu těchto vlaků (ukládá infromaci z jakých vagónů je tvořen např.) a míst (takže umožňuje vytvářet a spravovat tratě, stanice a hlavně jejich kapacitu).

Skript vytvářející hlavní schéma jsem rozdělil do dvou hlavních částí, kde jedna se stará o logiku správy jednotlivích míst a druhá o fungování a vytváření vlaků.

## Fungování Míst (PLACE LOGIC)
Tato část obsahuje tabulky Place, Station a Track, kde tabulky Station a Track jsou dědičné od Place a tabulka Place obsahuje pouze interní id. Tabulka Place existuje pouze pro to, aby v tabulce Train, kde se ukládá umístění vlaku mohlo být obecné id a informace se tak v tabulce jednodušeji ukládala.

Jelikož tabulka Train obsahuje cizí klíč do tabulky Place a existují triggery, které hlídají integritu tohoto vztahu, tak je v této sekci vytvořená tabulka Train. Ze stejného důvodu je vytvořena i tabulka CargoType, aby do ní mohla odkazovat tabulka Station. Většina triggerů hlídajících vlastnosti dat z těchto tabulek a příslušné procedury jsou vytvořené až v druhé části skriptu.

### Triggery
#### Place
- Place_Del_Trigger: kontroluje, jestli je možné místo smazat (jestli se v něm nenachází nějaké vlaky)
- Place_Ins_Upd_Trigger: kontroluje, že insert a update se dá provádět pouze pomocí procedur

#### Track
- Track_Ins_Trigger: generuje id pro nový záznam tabulky Track a zajišťuje, že bude existovat záznam v rodičivské tabulce Place
- Track_Del_Trigger: kontroluje, že delete lze provádět pouze z procedur, kde jsou ohlídané podmínky pro dobrou konzistenci dat

#### Station
- Station_Ins_Trigger: generuje id pro nový záznam a zajišťuje vložení do otcovské tabulky Place
- Station_Del_Trigger: kontroluje, že delete lze provádět pouze z procedur, kde jsou ohlídané podmínky pro dobrou konzistenci dat

### Package
#### Procedury pro tabulku CargoType
- addCargoType(jménoKomodity, jednotkaKomodity):
    - Vytvoří příslušnou komodity v tabulce, pokud splňuje podmínky pro vložení do tabulky dle integritních omezení
- removeCargoType(jménoKomodity):
    - Najde a smaže danou komoditu a upozorní pokud hledaná komodita neexistuje

#### Procedury pro tabulku Track
- addTrack(kód, délka, rychlostní limit, počet kolejí):
    - kód je unikátní identifikátor, pro uživatele
    - počet kolejí u trati určuje kapacitu vlaků, které mohou po trati současně jet
    - procedura přidá trať splňující integritní omezení do tabulky Track

- addDefaultTrack(kód, délka):
    - funguje jako předchozí procedura, ale za rychlostní limit doplní automaticky 160 a počet kolejí jako 1

- removeTrack(kód):
    - Pokud je kód existující, pak smaže trať identifikovanou vstupním kódem z tabulky Track
    - Kontroluje, zdali se na ní nevyskytují nějaké vlaky, pak se mazání neprovede

#### Procedury pro tabulku Station
- addStation(jménoStanice, kapacitaVlaků, komodita, kapacitaKomodity):
    - jménoStanice funguje jako identifikátor pro uživatele
    - kapacitVlaků určuje počet vlaků, který se vejde do stanice
    - komodita určuje co stanice obsluhuje (stanice pro pasažéry, uhlí atd.)
    - kapacita komodity určuje jaký objem daného zboží je schopna stanice obsloužit
    - procedura vloží do tabulky Station stanici, které splňuje integritní omezení

- removeStation(jménoStanice)
    - Smaže z tabulky příslušnou stanici, pokud existuje
    - Hlídá, jestli ve stanici nejsou žádné vlaky, aby pak nebyly vlaky na neexistujícím místě

#### Funkce pro vypočítání kapacity
- getStationCapacity(jménoStanice):
    - vypočte aktuální kapacitu stanice, pokud existuje
    - výpočet se provede odečtením aktuálního počtu vlaků v této stanici od kapacity stanice

- getTrackCapacity(kódTratě)
    - vypočte aktuální kapacitu tratě, pokud existuje
    - výpočet se provede odečtením aktuálního počtu vlaků na této trati od počtu kolejí tratě


## Fungování Vlaků (TRAIN LOGIC)
Zde jsou definované tabulky Car, Carriage, Locomotive, TrainRecipe a License. Car obsahuje obecné infromace o drážním vozidle, které jsou pak děděny do tabulek Carriage nebo Locomotive, podle toho jestli je drážní vozidlo vagón či lokomotiva.

Tabulka TrainRecipe udržuje informaci z jakých drážních vozidel se skládá jaký vlak. License pouze ukládá řídící licence pro různé vlaky (jakou licenci je nutné mít pro řízení lokomotivy).

### Triggery
#### License
- License_Del_Trigger: Hlídá jestli license není vyžadována nějakým vlakem při mazání
- License_Ins_Trigger: generuje id pro nový řádek

#### CargoType
- Cargo_Del_Trigger: hlídá, že mazaná komodita neexistuje v žádné stanici či vagónu
- Cargo_Ins_Trigger: generuje id pro nové řádky

#### Train
- Train_Ins_Trigger: generuje id pro nové řádky

#### Car
- Car_Ins_Trigger: hlídá, že inserty se provádí pouze z procedur
- Car_Del_Trigger: hlídá, že delete se provádí z procedury a že se nemaže vagón, který je připojený k nějakému vlaku

#### Carriage
- Carriage_Ins_Trigger: hlídá, že insert se provádí z procedury, generuje id pro nové řádky a vlkádá informace do otcovské tabulky Car
- Carriage_Del_Trigger: hlídá, že delete se provádí z procedury

#### Locomotive
- Locomotive_Ins_Trigger: hlídá, že insert se provádí z procedury, generuje id pro nové řádky a vlkádá informace do otcovské tabulky Car
- Locomotive_Del_Trigger: hlídá, že delete se provádí z procedury

#### TrainRecipe
- TrainRecipe_Ins_Trigger: hlídá, že vlak nebude přetížený po připojení vlaku a že vagón je nepoužívaný
- TrainRecipe_Upd_Trigger: zakazuje veškeré updaty nad tabulkou

### Package
#### Train
- createTrain(jménoVlaku, jménoStanice, prvníLokomotiva):
    - Vytváří nový vlak, pokud splňuje integritní omezení
    - hlídá, aby Stanice nebyla přeplněná

- removeTrain(jménoVlaku)
    - smaže existující vlak a uvolní tak všechny jeho vagóny

#### Procedury pro pohyb vlaků
- moveTrainToTrack(jménoVlaku, kódTrati):
    - přesune vlak na jinou trať bez závislosti na tom, kde byl vlak dřív
    - hlídá ovšem kapacitu nové trati a také jestli jde o existující entity

- moveTrainToStation(jménoVlaku, jménoStanice):
    - přesune vlak do jiné Stanice bez závislosti na tom, kde byl vlak dřív
    - hlídá ovšem kapacitu nové stanice a také jestli jde o existující entity

#### Carriage
- createCarriage(kód, značka, model, maximálníRychlost, váha, komodita, kapacitaKomodity):
    - kód je identifikátor vagónu pro uživatele
    - značka a model určují výrobce a modelovou řadu stroje
    - váha je váha vagónu v tunách
    - komodita a kapacitaKomodity fungují stejně jako u stanic
    - procedura vytvoří nový vagón, pokud vstupní data splňují integritní omezení pro vložení do tabulky

- removeCarriage(kód):
    - podle kódu najde a smaže existující vagón
    - řetězově se maže i záznam z tabulky Car a zkomtroluje se pak, jestli vagón nepatří k nějakému vlaku

#### Locomotive
- createLocomotive(kód, značka, model, maximálníRychlost, váha, váhováKapacita, kódLicense):
    - kód, značka, model, maximálníRychlost a váha fungují stějně jako u vagónů
    - váhováKapacita určuje jakou váhu lokomotiva utáhne (jde o její tažnou sílu v tunách)
    - kódLicense je kód license, která je potřebná k řízení vozu
    - procedura vytvoří novou lokomotivu, pokud vstupní data splňují integritní omezení pro vložení do tabulky

- removeLocomotive(kód):
    - podle kódu smaže existující lokomotivu
    - řetězově se maže i záznam z tabulky Car a zkomtroluje se pak, jestli lokomotiva nepatří k nějakému vlaku

#### License
- createLicense(kódLicense, popisLicense):
    - kódLicense je opět identifikátor pro uživatele
    - popisLicense může být libovolný text
    - vytvoří záznam a poku splňuje integritní omezení, tak jej vloží do tabulky License

- removeLicense(kódLicense):
    - smaže existující licensi
    - řetezově pak kontroluje, že license není vyžadována žádnou lokomotivou

#### Procedury pro WeightScore
- getWeightScoreOfTrain(idVlaku):
    - pro vlak spočte váhové skóre
    - počítá jej tak, že přičítá váhu jednostlivých vagónů a odčítá tažnou kapacitu lokomotiv
    - vlak je tedy funkční, pokud má váhové skóré menší rovno nule
    - jde o privátní funkci, kterou používají všechny procedury níže

- getWeightOfTrain(jménoVlaku)
    - jde o funkci, která zkontroluje existenci vlaku a pak spočte pomocí předchozí funkce jeho váhové skóre

- getWeightScoreOfTrainWithNewCar(idVlaku, idVozu):
    - spočte váhové skóre pro vlak pomocí procedury getWeightScoreOfTrain a pak přepočítá hypotetické skóre po přidání jednoho vozu
    - tato metoda je sice veřejná ovšem z důvodu nekontrolování existence id, tak je uživateli znepřístupněna
    - používá se pouze v triggeru, který kontroluje že po přidání vagónu k vlaku nebude vlak příliš těžký na lokomotivy

- getWeightScoreOfTrainWithoutLoco(idVlaku, idLokomotivy):
    - privátní funkce, která kontroluje, jestli po odebrání lokomotivy nebude vlak přetížený
    - používá k tomu funkci getWeightScoreOfTrain

#### TrainRecipe procedury
- addCarriageToTrain(jménoVlaku, kódVagonu):
    - pro existující vlak a vagón, který je volný, připojí vagón k vlaku
    - řetězově zkontroluje aby vlak nebyl přetížený

- removeCarriageFromTrain(jménoVlaku, kódVagónu):
    - pro existující vlak a vagón odpojí vagón od vlaku

- addLocmotiveToTrain(jménoVlaku, kódLokomotivy):
    - pro existující vlak a existující a volnou lokomotivu je spojí

- removeLocomotiveFromTrain(jménoVlaku, kódLokomotivy):
    - pro existující vlak a existující lokomotivu je rozpojí
    - řetězově zkontroluje, že vlak nebude po odpojení lokomotivy přetížen

## Pohledy
### Umístění vlaků
- StationsOccupancy: ukazuje jak jsou obsazené stanice
    - ukáže pro každou stanici, jaký je v ní vlak (pokud jich je více, pak je v pohledu více řádků)
    - pokud je stanice prázdná je ve druhém sloupci pomlčka
- TracksOccupancy: ukazuje jak jsou obsazené tratě, funguje stejně jako předchozí pohled pro tratě
- TrainPositions:
    - pro každý vlak ukazuje v jaké stanici či trati se zrovna nachází
    - v řádku je tak vždycky: jménoVlaku | - | jménoStanice (pokud je ve stanici), nebo: jménoVlaku | kódTratě | - (pokud je na trati)
- StationCapacities:
    - ukáže pro všechny stanice jakou mají aktuální kapacitu vlaků
- TrackCapacities:
    - ukáže pro včechny tratě jejich aktuální kapacity vlaků

### TrainRecipe
- CodeCars:
    - slouží k zobrazení všech drážních vozidel a jejich kódů, neboť kódy jsou specifické pro vagóny a lokomotivy zvlášť
- CarriageView:
    - ukáže kompletní infromace pro vagóny (takže i ty z otcovské tabulky Car)
- LocomotiveView:
    - stejné jako u CarriageView
- UnusedCars:
    - ukáže seznam drážnách vozidel, které nejsou zapojené do žádné valkové soupravy
- TrainRecipesView:
    - slouží k tomu, aby uživatel mohl sledovat z jakých drážních vozidel je sestavený jaký vlak
    - tabulka TrainRecipe obsahuje pouze strojová id a tak by informace pro uživatele mohla nesrozumitelná

### WeightScore
- TrainsWeightScore:
    - ukazuje seznam všech vlaků a pro každý jeho spočátané váhové skóre

## Chyby
V aplikaci jsou zavedené následující chybové kódy, které odpovídají různým situacím, které mohou nastat.
- -20080: Přetížený vlak
- -20085: Vztah s položkou již existuje a nelze vytvořit nový
- -20090: Snaha o provedení nedovolené operace s objektem
- -20095: hledaná položka neexistuje
- -20100: Mazaná položka je v relaci s jinými entitami a nemůže tak být odstraněna

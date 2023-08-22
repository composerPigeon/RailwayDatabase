# Databázová aplikace pro správu železnic

## Zadání práce
Jako zadání jsem si vybral databázovou aplikaci pro správu železniční infrastruktury. Aplikace tedy hlavně eviduje vlaky a jejich polohu. Dále umožňuje správu těchto vlaků (ukládá infromaci z jakých vagónů je tvořen např.) a míst (takže umožňuje vytvářet a spravovat tratě, stanice a hlavně jejich kapacitu).

Skript vytvářející hlavní schéma jsem rozdělil do dvou hlavních částí, kde jedna se stará o logiku správy jednotlivích míst a druhá o fungování a vytváření vlaků.

## Fungování Míst (PLACE LOGIC)
Tato část obsahuje tabulky Place, Station a Track, kde tabulky Station a Track jsou dědičné od Place a tabulka Place obsahuje pouze interní id. Tabulka Place existuje pouze pro to, aby v tabulce Train, kde se ukládá umístění vlaku mohlo být obecné id a informace se tak v tabulce jednodušeji ukládala.

Jelikož tabulka Train obsahuje cizí klíč do tabulky Place a existují triggery, které hlídají integritu tohoto vztahu, tak je v této sekci vytvořená tabulka Train. Ze stejného důvodu je vytvořena i tabulka CargoType, aby do ní mohla odkazovat tabulka Station. Většina triggerů hlídajících vlastnosti dat z těchto tabulek a příslušné procedury jsou vytvořené až v druhé části skriptu.

Triggery v této části hlídají následující vlastnosti:
- 

Package PlaceUI pak zajišťuje následující funkcionalitu:
- 

## Fungování Vlaků (TRAIN LOGIC)
Zde jsou definované tabulky Car, Carriage, Locomotive, TrainRecipe a License. Car obsahuje obecné infromace o drážním vozidle, které jsou pak děděny do tabulek Carriage nebo Locomotive, podle toho jestli je drážní vozidlo vagón či lokomotiva.


## Chyby
- -90080: Přetížený vlak
- -90085: Vztah s položkou již existuje a nelze vytvořit nový
- -90090: Snaha o provedení nedovolené operace s objektem
- -90095: hledaná položka neexistuje
- -90100: Mazaná položka je v relaci s jinými entitami a nemůže tak být odstraněna

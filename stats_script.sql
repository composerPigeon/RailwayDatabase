exec dbms_stats.gather_table_stats(user, 'CargoType', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'CARGOTYPE';

exec dbms_stats.gather_table_stats(user, 'Place', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'PLACE';

exec dbms_stats.gather_table_stats(user, 'Station', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'STATION';

exec dbms_stats.gather_table_stats(user, 'Track', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'TRACK';

exec dbms_stats.gather_table_stats(user, 'Train', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'TRAIN';

exec dbms_stats.gather_table_stats(user, 'Car', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'CAR';

exec dbms_stats.gather_table_stats(user, 'Carriage', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'CARRIAGE';

exec dbms_stats.gather_table_stats(user, 'Locomotive', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'LOCOMOTIVE';

exec dbms_stats.gather_table_stats(user, 'License', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'LICENSE';

exec dbms_stats.gather_table_stats(user, 'TrainRecipe', cascade => true);

select column_name, nullable, num_distinct, num_nulls, density, histogram
from ALL_TAB_COLUMNS
where table_name = 'TRAINRECIPE';
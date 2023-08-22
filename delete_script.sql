----DROP SEQUENCES----
drop sequence Seq_placeId;
drop sequence Seq_cargoId;
drop sequence Seq_trainId;
drop sequence Seq_carId;
drop sequence Seq_licenseId;

----DROP PKGs----
drop package PlaceUI;
drop package TrainUI;

----DROP STATS----
exec dbms_stats.delete_table_stats(user, 'Track');
exec dbms_stats.delete_table_stats(user, 'Station');
exec dbms_stats.delete_table_stats(user, 'TrainRecipe');
exec dbms_stats.delete_table_stats(user, 'Train');
exec dbms_stats.delete_table_stats(user, 'Place');
exec dbms_stats.delete_table_stats(user, 'Carriage');
exec dbms_stats.delete_table_stats(user, 'Locomotive');
exec dbms_stats.delete_table_stats(user, 'Car');
exec dbms_stats.delete_table_stats(user, 'License');
exec dbms_stats.delete_table_stats(user, 'CargoType');

----DROP TABLES----
drop table Track;
drop table Station;
drop table TrainRecipe;
drop table Train;
drop table Place;
drop table Carriage;
drop table Locomotive;
drop table Car;
drop table License;
drop table CargoType;


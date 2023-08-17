
----DROP TRIGGERS----
drop trigger Station_Del_Trigger;
drop trigger Station_Ins_Trigger;
drop trigger Track_Del_Trigger;
drop trigger Track_Ins_Trigger;
drop trigger Place_Ins_Upd_Trigger;
drop trigger Place_Del_Trigger;

drop trigger Cargo_Del_Trigger;
drop trigger Cargo_Ins_Trigger;
drop trigger License_Del_Trigger;
drop trigger License_Ins_Trigger;

drop trigger Train_Ins_Trigger;

----DROP SEQUENCES----
drop sequence Seq_placeId;
drop sequence Seq_cargoId;
drop sequence Seq_trainId;

----DROP PKGs----
drop package PlaceUI;
drop package TrainUI;

----DROP TABLES----
drop table Track;
drop table Station;
drop table TrainRecipe;
drop table Train;
drop table Place;
drop table Carriage;
drop table Drives;
drop table Locomotive;
drop table Car;
drop table HasLicense;
drop table License;
drop table TrainDriver;
drop table CargoType;


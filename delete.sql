----DROP SEQUENCES----
drop sequence Seq_placeId;
drop sequence Seq_cargoId;
drop sequence Seq_trainId;
drop sequence Seq_carId;
drop sequence Seq_licenseId;

----DROP VIEWS----
drop view TrainsWeightScore;
drop view TrainRecipesView;
drop view UnusedCars;
drop view LocomotiveView;
drop view CarriageView;
drop view CodeCars;
drop view TrainPositions;
drop view TracksOccupancy;
drop view StationsOccupancy;

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
drop table Locomotive;
drop table Car;
drop table License;
drop table CargoType;


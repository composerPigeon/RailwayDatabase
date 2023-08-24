----TEST VIEWS----

--Shows stations and trains that are there. If station is empty then there is just dash in Train column.
select * from StationsOccupancy;

--Same as the previous view, but wokrs for Tracks instead of Stations.
select * from TracksOccupancy;

--Shows Train, Track, Station and either Track or Station contains dash. It says where the train currently is.
select * from TrainPositions;

--Shows capacities of stations
select * from StationCapacities;

--Shows capacities of Tracks
select * from TrackCapacities;

--Shows Cara but with code that is from Locomotive or Carriage table, so it is not needed tp be saved two times.
select * from CodeCars;

--Shows info of Carriages with cols saved in Car
select * from CarriageView;

--Shows info of Lcomotive  with columns that are saved in Car table
select * from LocomotiveView;

--Shows all Cars that aren't connected to any trains. It shows also their codes.
select * from UnusedCars;

--Shows more useful information about which Car is connected to which Train.
select * from TrainRecipesView;

--Shows WeightScore for each train.
select * from TrainsWeightScore;

----TEST OF PLACEUI----

--addCargoType was used in insert_data script. There is just filled table.
select * from CargoType;

--This will fail because this comodity already exists so it broke UNIQUE CONSTRAINT in CargoType table
exec PlaceUI.addCargoType('Passangers', 'p');

--This will not remove wood, beacuse there is carriage C201 that has a wood comodity and it will end with application error
exec PlaceUI.removeCargoType('Wood');

exec TrainUI.removeCarriage('C201');

--To se carriage was removed
select * from CarriageView;

exec PlaceUI.removeCargoType('Wood');

--To see wood was removed
select * from CargoType;

--Removing nonexistent comodity will end with application error
exec PlaceUI.removeCargoType('Blabla');

--This will fail because Track of this code already exists (it will break unique constraint)
exec PlaceUI.addDefaultTrack('TR0001', 100);

--This will fail because of the same reason as failed the previous one
exec PlaceUI.addTrack('TR0001', 100, 100, 1);

--This will just move train to track
exec TrainUI.moveTrainToTrack('MostExp1', 'TR0001');

--You can see there that the train moved
select * from TracksOccupancy;

--This will fail because there is a train at this track, it will end with application error
exec PlaceUI.removeTrack('TR0001');

--There you can see that there is a train on TR0001\
select * from TrainPositions;

--Our train moved from Most to Pilsen by Track TR0001
exec TrainUI.moveTrainToStation('MostExp1', 'Pilsen');

--Here you can see train moved to station Pilsen
select * from TrainPositions;

--when track is empty it can be removed
exec PlaceUI.removeTrack('TR0001');

--Track TR0001 is now remvoed
select * from Track;

--This will end with appliccation error because this track no longer exist
exec PlaceUI.removeTrack('TR0001');

--This will fail because Vejprnice already exist and it broke unique constraint for table Station
exec PlaceUI.addStation('Vejprnice', 3, 'Coal', 100);

--This will fail because Wood comodity now do not exist. It will end with application error.
exec PlaceUI.addStation('Morava', 5, 'Wood', 100);

--This will end with application error, because it si not possible to remove station with trains in it
exec PlaceUI.removeStation('Vejprnice');

--This will end with application error, because it si not possible to remove station that do not exist
exec PlaceUI.removeStation('Blabla');

--This will remove Most coal mines station
exec PlaceUI.removeStation('Most coal mines');

select * from Station;

--TODO: test train logic
--This procedure will fail, because capacity of vejprnice is full. It will end with application error
exec TrainUI.moveTrainToStation('MostExp1', 'Vejprnice');

--This one will fail, beacuse station blabla does not exist. It will end with application error
exec TrainUI.moveTrainToStation('MostExp1', 'Blabla');

--This will fail, because train blabla does not exist. It will end with application error
exec TrainUI.moveTrainToStation('Blabla', 'Prague');

--This will move train to track
exec TrainUI.moveTrainToTrack('MostExp1', 'TR0003');

select * from TrainPositions;

--This will fail, because TR0003 is occupied. It will end with application error
exec TrainUI.moveTrainToTrack('Berounka1', 'TR0003');

--This will fail, because inputed track does not exist. It will end with application error
exec TrainUI.moveTrainToTrack('Berounka1', 'TRblah');

--This will fail, because train Blabla does not exist. It will end with application error.
exec TrainUI.moveTrainToTrack('Blabla', 'TR0002');


--This will fail, because Berounka1 already exist. It will break the unique constraint for Train table.
exec TrainUI.createTrain('Berounka1', 'Prague', 'L502');

--This will fail, beacuse station Vejprnice is occupied. It will end with application error.
exec TrainUI.createTrain('NewTrain', 'Vejprnice', 'L502');

select * from Train;

--This will fail, because station Blabla does not exist. It will end with application error.
exec TrainUI.createTrain('NewTrain', 'Blabla', 'L502');

--This will fail, because locomotive blah does not exist. It will end with application error.
exec TrainUI.createTrain('NewTrain', 'Prague', 'Blah');

--This will remove train. All cars of the train will become unused.
exec TrainUI.removeTrain('Berounka4');

select * from Train;

--There is now L004 from Berounka4
select * from UnusedCars;

--This will fail, because train blabla does not exist. It will end with application error
exec TrainUI.removeTrain('Blabla');

--This will fail, because carriage C001 already exists. It will break the unique constraint in table Carriage
exec TrainUI.createCarriage('C001', 'Skoda', 'super speed', 250, 20, 'Passangers', 100);

--This will fail, because comodity wood does not exist. It will end with application error
exec TrainUI.createCarriage('C007', 'Skoda', 'super speed', 250, 20, 'Wood', 100);

--This will add Carriage with default speed of 160
exec TrainUI.createCarriage('C006', 'Skoda', 'P 100', null, 20, 'Passangers', 100);

select * from CodeCars;

--This will remove the carriage C006
exec TrainUI.removeCarriage('C006');

select * from CodeCars;

--This will fail, because carriage of inputed code does not exist. It will end with applicaion error
exec TrainUI.removeCarriage('Blah');

--This will fail, because this carrige is connected to train. It will end with application error
exec TrainUI.removeCarriage('C001');

--This will fail, beacuse locomotive L001 already exists. It will break unique constraint in table Locomotive
exec TrainUI.createLocomotive('L001', 'Skoda', 'super speed', 250, 20, 100, 'LIC1');

--This will fail, because license code blah does not exist. It will end with application error
exec TrainUI.createLocomotive('L005', 'Skoda', 'super speed', 250, 20, 100, 'Blah');

--This will add Locomotive with default speed of 160
exec TrainUI.createLocomotive('L005', 'Skoda', 'super speed', null, 20, 100, 'LIC1');

--This will remove the locomotive L005
exec TrainUI.removeLocomotive('L005')

select * from CodeCars;

--This will fail, because locomotive L001 is connected inside a train. It will end with application error
exec TrainUI.removeLocomotive('L001');

--This won't work, because locomotive of code blah does not exist. It will end with application error
exec TrainUI.removeLocomotive('Blah');

--This will fail, beacuse license LIC1 already exist. It will break unique constraint in table License
exec TrainUI.createLicense('LIC1', 'For passanger trains');

--This will add license
exec TrainUI.createLicense('LIC3', 'New testing license');

select * from License;

--This will remove license
exec TrainUI.removeLicense('LIC3');

select * from License;

--This will fail, because license of code LIC1 is used by some locomotives. It will end with application error
exec TrainUI.removeLicense('LIC1');

--This will fail, because license of code blah does not exist. It will end with application error.
exec TrainUI.removeLicense('Blah');

--This will return weight score for train berounka1
select TrainUI.getWeightOfTrain('Berounka1') Berounka1_WeightScore from Dual;

--This will fail with application error, because train blabla does not exist
select TrainUI.getWeightOfTrain('Blabla') Blabla_WeightScore from Dual;

--This will fail with application error, because user do not have access to use this method.
select TrainUI.getWeightScoreOfTrainWithNewCar(1, 1) from Dual;

--This will fail with application error, because berounka will become overweighted
exec TrainUI.addCarriageToTrain('Berounka1', 'C005');

--This will fail with application error, beacsue car is already used
exec TrainUI.addCarriageToTrain('Berounka2', 'C001');

--This will fail with application error, because car is already connected to this train
exec TrainUI.addCarriageToTrain('MostExp1', 'C101');

--This will fail with application error, because train blabla does not exist
exec TrainUI.addCarriageToTrain('Blabla', 'C005');

--This will fail with application error, because carriage Blah does not exist
exec TrainUI.addCarriageToTrain('MostExp1', 'Blah');

--There it will remove carriage C004 from Berounka1
select * from TrainRecipesView;

exec TrainUI.removeCarriageFromTrain('Berounka1', 'C004');

select * from TrainRecipesView;

select * from UnusedCars;

--This will fail with application error, because carriage blah does not exist
exec TrainUI.removeCarriageFromTrain('MostExp1', 'Blah');

--This will fail with applicatiion error, because train blabla does not exist
exec TrainUI.removeCarriageFromTrain('Blabla', 'C004');

--This will fail with application error, because car is already used
exec TrainUI.addLocomotiveToTrain('Berounka2', 'L001');

--This will fail with application error, because car is already connected to this train
exec TrainUI.addLocomotiveToTrain('Berounka2', 'L002');

--This will fail with application error, because train blabla does not exist
exec TrainUI.addLocomotiveToTrain('Blabla', 'C005');

--This will fail with application error, because carriage Blah does not exist
exec TrainUI.addLocomotiveToTrain('MostExp1', 'Blah');

--This will add locomotive to train
exec TrainUI.addLocomotiveToTrain('Berounka1', 'L004');

select * from TrainRecipesView;

--This will remove locomotive from train
exec TrainUI.removeLocomotiveFromTrain('Berounka1', 'L004');

select * from TrainRecipesView;

--This will fail with application error, because Train without locomotive will become overweighted
exec TrainUI.removeLocomotiveFromTrain('Berounka1', 'L001');

--This will remove locomotive from train, but also delete the train (there cant be empty trains)
exec TrainUI.removeLocomotiveFromTrain('Berounka2', 'L002');

select * from TrainRecipesView;

select * from Train;

--This will fail with application error, because train blabla does not exist
exec TrainUI.removeLocomotiveFromTrain('Blabla', 'L004');

--This will fail with application erorr, because locomotive blah does not exist
exec TrainUI.removeLocomotiveFromTrain('Berounka1', 'Blah')
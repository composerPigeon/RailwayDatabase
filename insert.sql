----INSERT TO CARGOTYPE----
exec PlaceUI.addCargoType('Passangers', 'p');
exec PlaceUI.addCargoType('Coal', 't');
exec PlaceUI.addCargoType('Wood', 't');

----INSERT STATIONS----
exec PlaceUI.addStation('Prague', 15, 'Passangers', 100000);
exec PlaceUI.addStation('Pilsen', 10, 'Passangers', 50000);
exec PlaceUI.addStation('Vejprnice', 3, 'Passangers', 300);
exec PlaceUI.addStation('Most coal mines', 5, 'Coal', 30);

----INSERT TRACKS----
exec PlaceUI.addDefaultTrack('TR0001', 150);
exec PlaceUI.addTrack('TR0002', 100, 200, 2);
exec PlaceUI.addTrack('TR0003', 10, 80, 1);

----INSERT LICENSES----
exec TrainUI.createLicense('LIC1', 'License for speed trains');
exec TrainUI.createLicense('LIC2', 'License for coal trains');

----INSERT CARRIAGES----
--passanger carriages
exec TrainUI.createCarriage('C001', 'Skoda', 'P 100', 200, 20, 'Passangers', 60);
exec TrainUI.createCarriage('C002', 'Skoda', 'P 100', 200, 20, 'Passangers', 60);
exec TrainUI.createCarriage('C003', 'Skoda', 'P 100', 200, 20, 'Passangers', 60);
exec TrainUI.createCarriage('C004', 'Skoda', 'P 100', 200, 20, 'Passangers', 60);
exec TrainUI.createCarriage('C005', 'Skoda', 'P 100', 200, 20, 'Passangers', 60);

--coal carriages
exec TrainUI.createCarriage('C101', 'Siemens', 'Coal 35', 100, 40, 'Coal', 35);
exec TrainUI.createCarriage('C102', 'Siemens', 'Coal 35', 100, 40, 'Coal', 35);
exec TrainUI.createCarriage('C103', 'Siemens', 'Coal 35', 100, 40, 'Coal', 35);
exec TrainUI.createCarriage('C104', 'Siemens', 'Coal 35', 100, 40, 'Coal', 35);

--wood carriage
exec TrainUI.createCarriage('C201', 'Siemens', 'Wood 10', 100, 25, 'Wood', 10);



----INSERT LOCOMOTIVES----
--speed trains
exec TrainUI.createLocomotive('L001', 'Skoda', 'Super speed', 250, 20, 100, 'LIC1');
exec TrainUI.createLocomotive('L002', 'Skoda', 'Super speed', 250, 20, 100, 'LIC1');
exec TrainUI.createLocomotive('L003', 'Skoda', 'Super speed', 250, 20, 100, 'LIC1');
exec TrainUI.createLocomotive('L004', 'Skoda', 'Super speed', 250, 20, 100, 'LIC1');

--freight trains
exec TrainUI.createLocomotive('L501', 'Siemens', 'Heavy load', 100, 30, 200, 'LIC2');
exec TrainUI.createLocomotive('L502', 'Siemens', 'Heavy load', 100, 30, 200, 'LIC2');


----INSERT TRAIN----
exec TrainUI.createTrain('Berounka1', 'Prague', 'L001');
exec TrainUI.createTrain('Berounka2', 'Vejprnice', 'L002');
exec TrainUI.createTrain('Berounka3', 'Vejprnice', 'L003');
exec TrainUI.createTrain('Berounka4', 'Vejprnice', 'L004');
exec TrainUI.createTrain('MostExp1', 'Most coal mines', 'L501');

----INSERT TRAINRECIPE----
exec TrainUI.addCarriageToTrain('Berounka1', 'C001');
exec TrainUI.addCarriageToTrain('Berounka1', 'C002');
exec TrainUI.addCarriageToTrain('Berounka1', 'C003');
exec TrainUI.addCarriageToTrain('Berounka1', 'C004');

exec TrainUI.addCarriageToTrain('MostExp1', 'C101');
exec TrainUI.addCarriageToTrain('MostExp1', 'C102');
exec TrainUI.addCarriageToTrain('MostExp1', 'C103');



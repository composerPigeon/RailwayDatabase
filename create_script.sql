------PLACE_LOGIC TABLES------
create table CargoType (
    id integer
        constraint CargoType_id_PK primary key,
    comodity varchar2(50) not null
        constraint CargoType_comodity_Unique unique,
    unit character(2) not null
);

create table Place(
    id integer
        constraint Place_PK primary key
);

create table Train(
    id integer
        constraint Train_id_PK primary key,
    name varchar2(50 char) not null
        constraint Train_name_Unique unique,
    placeId integer not null
        constraint Train_placeId_FK_Place
            references Place(id)
);

create index Train_placeId_Inx on Train(placeId);

create table Track(
    id integer
        constraint Track_id_PK primary key
        constraint Track_id_FK_Place
            references Place(id)
            on delete cascade,
    code character(6) not null
        constraint Track_code_Unique unique,
    length number(5, 0)
        constraint Track_length_gt0 check(length > 0),
    speedLimit number(3, 0) default 160
        constraint Track_speedLimit_gt0 check(speedLimit > 0),
    numOfRails number(1, 0) default 1 not null,
        constraint Track_numOfRails_gt0 check(numOfRails > 0)
);

create table Station(
    id integer
        constraint Station_id_PK primary key
        constraint Station_id_FK_Place
            references Place(id)
            on delete cascade,
    name varchar2(50 char) not null
        constraint Station_name_Unique unique,
    trainCapacity number(4, 0) not null
        constraint Station_trainCap_gt0 check(trainCapacity > 0),
    cargoTypeId integer not null
        constraint Station_cargoTypeId_FK_CargoType
            references CargoType(id),
    cargoCapacity number
        constraint Station_cargoCap_gt0 check(cargoCapacity > 0)
);

create index Station_cargoTypeId_Inx on Station(cargoTypeId);

------PLACE_LOGIC PKG------

create or replace package PlaceUI as
    childDeletes boolean := false;
    parentInserts boolean := false;

    procedure addCargoType(
        in_comodity CargoType.comodity%type,
        in_unit CargoType.unit%type
    );
    procedure removeCargoType(
        in_comodity CargoType.comodity%type
    );
    procedure addTrack(
        in_code Track.code%type,
        in_length Track.length%type,
        in_speedLimit Track.speedLimit%type,
        in_numOfRails Track.numOfRails%type
    );
    procedure addDefaultTrack(
        in_code Track.code%type,
        in_length Track.length%type
    );
    procedure removeTrack(
        in_code Track.code%type
    );
    procedure addPassangerStation(
        in_name Station.name%type,
        in_trainCapacity Station.trainCapacity%type,
        in_cargoCapacity Station.cargoCapacity%type
    );
    procedure addStation(
        in_name Station.name%type,
        in_trainCapacity Station.trainCapacity%type,
        in_cargoComodity CargoType.comodity%type,
        in_cargoCapacity Station.cargoCapacity%type
    );
    procedure removeStation(
        in_name Station.name%type
    );
end PlaceUI;
/

create or replace package body PlaceUI as
    procedure addCargoType(
        in_comodity CargoType.comodity%type,
        in_unit CargoType.unit%type
    ) is
    begin
        insert into CargoType(comodity, unit) values (in_comodity, in_unit);
    end addCargoType;

    procedure removeCargoType(
        in_comodity CargoType.comodity%type
    ) is
    begin
        delete from CargoType where comodity=in_comodity;
    end removeCargoType;

    procedure addTrack(
        in_code Track.code%type,
        in_length Track.length%type,
        in_speedLimit Track.speedLimit%type,
        in_numOfRails Track.numOfRails%type
    ) is
    begin
        parentInserts := true;
        insert into Track(code, length, speedLimit, numOfRails)
            values (in_code, in_length, in_speedLimit, in_numOfRails);
        parentInserts := false;
    end addTrack;

    procedure addDefaultTrack(
        in_code Track.code%type,
        in_length Track.length%type
    ) is
    begin
        parentInserts := true;
        insert into Track(code, length) values (in_code, in_length);
        parentInserts := false;
    end addDefaultTrack;

    procedure removeTrack(
        in_code Track.code%type
    ) is
        del_id Track.id%type;
    begin
        select id into del_id from Track where code=in_code;

        --
        childDeletes := true;
        delete from Place where id=del_id;
        childDeletes := false;

        exception
            when no_data_found then
                raise_application_error(-20095, 'Track of inputed code does not exists.');
    end removeTrack;

    procedure addPassangerStation(
        in_name Station.name%type,
        in_trainCapacity Station.trainCapacity%type,
        in_cargoCapacity Station.cargoCapacity%type
    ) is
        cargo_id CargoType.id%type;
    begin
        select id into cargo_id from CargoType where comodity='pasažéři';

        parentInserts := true;
        insert into Station(name, trainCapacity, cargoTypeId, cargoCapacity)
            values (in_name, in_trainCapacity, cargo_id, in_cargoCapacity);
        parentInserts := false;

        exception
          when no_data_found then
            raise_application_error(-20095, 'Inputed cargo type does not exists in CargoType table.');
    end addPassangerStation;

    procedure addStation(
        in_name Station.name%type,
        in_trainCapacity Station.trainCapacity%type,
        in_cargoComodity CargoType.comodity%type,
        in_cargoCapacity Station.cargoCapacity%type
    ) is
        cargo_id CargoType.id%type;
    begin
        select id into cargo_id from CargoType where comodity=in_cargoComodity;

        parentInserts := true;
        insert into Station(name, trainCapacity, cargoTypeId, cargoCapacity)
            values(in_name, in_trainCapacity, cargo_id, in_cargoCapacity);
        parentInserts := false;

        exception
          when no_data_found then
            raise_application_error(-20095, 'Inputed cargo type does not exists in CargoType table.');
    end addStation;

    procedure removeStation(
        in_name Station.name%type
    ) is
        del_id Station.id%type;
    begin
        select id into del_id from Station where name=in_name;

        childDeletes := true;
        delete from Place where id=del_id;
        childDeletes := false;
        
        exception
            when no_data_found then
                raise_application_error(-20095, 'Station of inputed name does not exists.');
    end removeStation;
end PlaceUI;
/

------PLACE_LOGIC TRIGGERS------
--PLACE TRIGGERS
--checks if trains are in a deleted place
create or replace trigger Place_Del_Trigger
before delete on Place
for each row
declare
    trains_count integer := 0;
begin
    select count(*) into trains_count from Train where placeId=:old.id;

    if trains_count != 0 then
        raise_application_error(-20100, 'Place cannot be deleted with trains in it');
    end if;
end;
/

--checks whether insert or update can be performed
create or replace trigger Place_Ins_Upd_Trigger
before insert or update on Place
begin
    if not PlaceUI.parentInserts then
        if updating then
            raise_application_error(-20090, 'Updates are prohibited for table Place');
        else
            raise_application_error(-20090, 'Inserts are prohibited for table Place');
        end if;
    end if;
end;
/

--sequence for placeIds
create sequence Seq_placeId start with 1 increment by 1;

--TRACK TRIGGERS
--generates id for insert
create or replace trigger Track_Ins_Trigger
before insert on Track
for each row
declare
    new_id Track.id%type;
begin
    select Seq_placeId.nextval into new_id from Dual;
    insert into Place(id) values(new_id);
    :new.id := new_id;
end;
/

--abort delete if not triggered from procedure
create or replace trigger Track_Del_Trigger
before delete on Track
begin
    if not PlaceUI.childDeletes then
        raise_application_error(-20090, 'Deletes are prohibited for table Track');
    end if;
end;
/


--STATION TRIGGERS
create or replace trigger Station_Ins_Trigger
before insert on Station
for each row
declare
    new_id integer;
begin
    select Seq_placeId.nextval into new_id from Dual;

    insert into Place(id) values(new_id);

    :new.id := new_id;
end;
/

--abort delete if not triggered from procedure
create or replace trigger Station_Del_Trigger
before delete on Station
begin
    if not PlaceUI.childDeletes then
        raise_application_error(-20090, 'Deletes are prohibited for table Station');
    end if;
end;
/


------TRAIN_LOGIC TABLES------
create table Car (
    id integer
        constraint Car_id_PK primary key,
    brand varchar2(50) not null,
    model varchar2(50) not null,
    maxSpeed number(3, 0) default 160 not null
        constraint Car_maxSpeed_gt0 check(maxSpeed > 0),
    weight number not null
        constraint Car_maxWeight_gt0 check(weight > 0)
);

create table Carriage (
    id integer
        constraint Carriage_id_PK primary key
        constraint Carriage_id_FK_Car
            references Car(id)
            on delete cascade,
    code character(4) not null
        constraint Carriage_code_Unique unique,
    cargoTypeId integer not null
        constraint Carriage_cargoTypeId_FK_CargoType
            references CargoType(id),
    capacity number
        constraint Carriage_cap_gt0 check(capacity > 0)
);

create index Carriage_cargoTypeId_Inx on Carriage(cargoTypeId);

create table License (
    id integer
        constraint License_id_PK primary key,
    code char(4) not null
        constraint License_code_Unique unique,
    description varchar2(50 char)
);

create table Locomotive (
    id integer
        constraint Locomotive_id_PK primary key
        constraint Locomotive_id_FK_Car
            references Car(id)
            on delete cascade,
    code character(4) not null
        constraint Locomotive_code_Unique unique,
    weightCapacity number
        constraint Locomotive_weightCapacity_gt0 check(weightCapacity > 0),
    licenseId integer
        constraint Locomotive_licenseId_FK_License
            references License(id)
);

create index Locomotive_licenseId_inx on Locomotive(licenseId);

create table TrainRecipe (
    trainId integer
        constraint TrainRecipe_trainId_FK_Train
            references Train(id)
            on delete cascade,
    carId integer
        constraint TrainRecipe_carId_FK_Car
            references Car(id)
            on delete cascade,
    constraint TrainRecipe_PK primary key (trainId, carId)
);

create index TrainRecipe_trainId_Inx on TrainRecipe(trainId);
create index TrainRecipe_carId_Inx on TrainRecipe(carId);

----TRAIN_LOGIC PKG----
create or replace package TrainUI as
    fromProcedure boolean := false;
    fromTrigger boolean := false;

    procedure createTrain(
        in_name Train.name%type,
        in_stationName Station.name%type,
        in_carId Car.id%type --this is first car with wich you will start your train
    );
    procedure removeTrain(
        in_name Train.name%type
    );
    procedure moveTrainToTrack(
        in_trainName Train.name%type,
        in_code Track.code%type
    );
    procedure moveTrainToStation(
        in_trainName Train.name%type,
        in_name Station.name%type
    );
    
    procedure createCarriage(
        in_code Carriage.code%type,
        in_brand Car.brand%type,
        in_model Car.model%type,
        in_maxSpeed Car.maxSpeed%type, --If null, than default value is 160
        in_weight Car.weight%type,
        in_cargoComodity CargoType.comodity%type,
        in_capacity Carriage.capacity%type
    );
    procedure createLocomotive(
        in_code Locomotive.code%type,
        in_brand Car.brand%type,
        in_model Car.model%type,
        in_maxSpeed Car.maxSpeed%type, --If null, than default value is 160
        in_weight Car.weight%type,
        in_weightCap Locomotive.weightCapacity%type,
        in_licenseCode License.code%type
    );
    procedure removeCarriage(
        in_code Carriage.code%type
    );
    procedure removeLocomotive(
        in_code Locomotive.code%type
    );

    procedure createLicense(
        in_code License.code%type,
        in_desc License.description%type
    );
    procedure removeLicense(
        in_code License.code%type
    );

    function getWeightOfTrain(
        in_name Train.name%type
    ) return Car.weight%type;
    function getWeightScoreOfTrainWithNewCar(
        in_trainId Train.id%type,
        in_carId Car.id%type
    ) return Car.weight%type;

    procedure addCarriageToTrain(
        in_name Train.name%type,
        in_code Carriage.code%type
    );
    procedure addLocomotiveToTrain(
        in_name Train.name%type,
        in_code Locomotive.code%type
    );
    procedure removeCarriageFromTrain(
        in_name Train.name%type,
        in_code Carriage.code%type
    );
    procedure removeLocomotiveFromTrain(
        in_name Train.name%type,
        in_code Locomotive.code%type
    );
end TrainUI;
/

create or replace package body TrainUI as
    --Procedures for table Train
    procedure createTrain(
        in_name Train.name%type,
        in_stationName Station.name%type,
        in_carId Car.id%type --this is first car with wich you will start your train --this is first car with wich you will start your train
    ) is
        in_trainId Train.id%type;
        in_placeId Place.id%type;
        train_count Station.trainCapacity%type;
        train_cap Station.trainCapacity%type;
    begin
        select id, trainCapacity into in_placeId, train_cap from Station where name=in_stationName;

        select count(*) into train_count from Train where placeId=in_placeId;

        if train_count < train_cap then
            insert into Train(name, placeId) values (in_name, in_placeId);

            select id into in_trainId from Train where name=in_name;

            insert into TrainRecipe(trainId, carId) values (in_trainId, in_carId);
        else
            raise_application_error(-90085, 'Station is occupied by other trains.');
        end if;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Station of inputed name does not exist.');
    end createTrain;

    procedure removeTrain(
        in_name Train.name%type
    ) is
        train_id  Train.id%type;
    begin
        select id into train_id from Train where name=in_name;
        delete from Train where name=in_name;

    exception
        when no_data_found then
            raise_application_error(-90095, 'Train of inputed name does not exist.');
    end removeTrain;

    procedure moveTrainToTrack(
        in_trainName Train.name%type,
        in_code Track.code%type
    ) is
        train_count integer := 0;
        rail_count Track.numOfRails%type;
        track_id Track.id%type;
    begin
        select nvl(id, null), nvl(numOfRails, null) into track_id, rail_count from Track where code=in_code;
        select count(*) into train_count from Train where placeId=track_id;
        
        if track_id is not null then
            if train_count < rail_count then
                update Train set placeId=track_id where name=in_trainName;
                if sql%rowcount = 0 then
                    raise_application_error(-90095, 'Inputed train does not exist.');
                end if;
            else
                raise_application_error(-90085, 'Train can not be moved, because selected track is occupied.');
            end if;
        else
            raise_application_error(-90095, 'Inputed track does not exist.');
        end if;
    end moveTrainToTrack;

    procedure moveTrainToStation(
        in_trainName Train.name%type,
        in_name Station.name%type
    )is
        station_cap Station.trainCapacity%type;
        station_id Station.id%type;
        train_count integer := 0;
        train_id Train.id%type;
    begin
        select nvl(id, null), nvl(trainCapacity, null) into station_id, station_cap from Station where name=in_name;
        select count(*) into train_count from Train where placeId=station_id;

        if station_id is not null then
            if train_count < station_cap then
                update Train set placeId=station_id where name=in_trainName;
                if sql%rowcount = 0 then
                    raise_application_error(-90095, 'Inputed train does not exist.');
                end if;
            else
                raise_application_error(-90085, 'Train can not be moved, because selected Stations capacity is full.');
            end if;
        else
            raise_application_error(-90095, 'Inputed station does not exist.');
        end if;
    end moveTrainToStation;

    --Procedures for tables Car, Carriage, Locomotive
    procedure createCarriage(
        in_code Carriage.code%type,
        in_brand Car.brand%type,
        in_model Car.model%type,
        in_maxSpeed Car.maxSpeed%type, --If null, than default value is 160
        in_weight Car.weight%type,
        in_cargoComodity CargoType.comodity%type,
        in_capacity Carriage.capacity%type
    ) is
        in_cargoTypeId CargoType.id%type;
        car_id Car.id%type;
    begin
        select id into in_cargoTypeId from CargoType where comodity=in_cargoComodity;

        TrainUI.fromProcedure := true;

        insert into Carriage(code, cargoTypeId, capacity) values (in_code, in_cargoTypeId, in_capacity);
        select id into car_id from Carriage where code=in_code;

        if in_maxSpeed is not null then
            update Car set brand=in_brand, model=in_model, maxSpeed=in_maxSpeed, weight=in_weight where id=car_id;
        else
            update Car set brand=in_brand, model=in_model, weight=in_weight where id=car_id;
        end if;
        TrainUI.fromProcedure := false;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Given cargoType comodity does not exist.');
    end createCarriage;

    procedure createLocomotive(
        in_code Locomotive.code%type,
        in_brand Car.brand%type,
        in_model Car.model%type,
        in_maxSpeed Car.maxSpeed%type, --If null, than default value is 160
        in_weight Car.weight%type,
        in_weightCap Locomotive.weightCapacity%type,
        in_licenseCode License.code%type
    ) is
        in_licenseId License.id%type;
        car_id Car.id%type;
    begin
        select id into in_licenseId from License where code=in_licenseCode;

        TrainUI.fromProcedure := true;
        insert into Locomotive(code, weightCapacity, licenseId) values (in_code, in_weightCap, in_licenseId);
        select id into car_id from Locomotive where code=in_code;

        if in_maxSpeed is not null then
            update Car set brand=in_brand, model=in_model, maxSpeed=in_maxSpeed, weight=in_weight where id=car_id;
        else
            update Car set brand=in_brand, model=in_model, weight=in_weight where id=car_id;
        end if;
        TrainUI.fromProcedure := false;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Given license does not exist.');
    
    end createLocomotive;

    procedure removeCarriage(
        in_code Carriage.code%type
    )is
        car_id Car.id%type;
    begin
        select id into car_id from Carriage where code=in_code;
        TrainUI.fromProcedure := true;
        delete from Car where id=car_id;
        TrainUI.fromProcedure := false;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Carriage of inputed code does not exist.');
    end removeCarriage;

    procedure removeLocomotive(
        in_code Locomotive.code%type
    ) is
        car_id Car.id%type;
    begin
        select id into car_id from Locomotive where code=in_code;
        TrainUI.fromProcedure := true;
        delete from Car where id=car_id;
        TrainUI.fromProcedure := false;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Locomotive of inputed code does not exist.');
    end removeLocomotive;

    --Procedures for License table
    procedure createLicense(
        in_code License.code%type,
        in_desc License.description%type
    ) is
    begin
        insert into License(code, description) values (in_code, in_desc);
    end createLicense;

    procedure removeLicense(
        in_code License.code%type
    ) is
        licenseId License.id%type;
    begin
        select id into licenseId from License where code=in_code;
        delete from License where id=licenseId;
    exception
        when no_data_found then
            raise_application_error(-90095, 'License of inputed id does not exist.');
    end removeLicense;

    --Functions computing wieght score of trains
    function getWeightScoreOfTrain(
        in_id Train.id%type
    ) return Car.weight%type
    is
        cursor train_cursor is
            select * from TrainRecipe where trainId=in_id;

        is_in_carriage number(1, 0) := 0;
        car_weight Car.weight%type;
        locoCapacity Locomotive.weightCapacity%type;
        
        weight_score Car.weight%type;
    begin
        for recipe in train_cursor loop
            select count(*) into is_in_carriage from Carriage where id=recipe.carId;
            select weight into car_weight from Car where id=recipe.carId;

            if is_in_carriage = 1 then
                weight_score := weight_score + car_weight;
            else
                select weightCapacity into locoCapacity from Locomotive where id=recipe.carId;
                weight_score := weight_score + car_weight - locoCapacity;
            end if;
        end loop;
        
        return weight_score;
    end getWeightScoreOfTrain;

    function getWeightOfTrain(
        in_name Train.name%type
    ) return Car.weight%type
    is
        train_id Train.id%type;
        weight Car.weight%type;
    begin
        select id into train_id from Train where name=in_name;
        weight := getWeightScoreOfTrain(train_id);

        return weight;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Train of inputed name does not exist.');
    end getWeightOfTrain;

    function getWeightScoreOfTrainWithNewCar(
        in_trainId Train.id%type,
        in_carId Car.id%type
    ) return Car.weight%type
    is
        is_in_carriage number(1, 0) := 0;
        locoCapacity Locomotive.weightCapacity%type;
        car_weight Car.weight%type;
        
         weight_score Car.weight%type;
    begin
        if fromTrigger then
            weight_score := getWeightScoreOfTrain(in_trainId);

            select weight into car_weight from Car where id=in_carId;
            select count(*) into is_in_carriage from Carriage where id=in_carId;

            weight_score := weight_score + car_weight;
            if is_in_carriage = 0 then
                select weightCapacity into locoCapacity from Locomotive where id=in_carId;
                weight_score := weight_score - locoCapacity;
            end if;

            return weight_score;
        else
            raise_application_error(-90090, 'This function cannot be executed by user.');
        end if;
    end getWeightScoreOfTrainWithNewCar;

    --Procedures for connecting cars into a train
    procedure addCarriageToTrain(
        in_name Train.name%type,
        in_code Carriage.code%type
    ) is
        in_trainId Train.id%type;
        in_carId Car.id%type; 
    begin
        select id into in_trainId from Train where name=in_name;
        select id into in_carId from Carriage where code=in_code;

        insert into TrainRecipe(trainId, carId) values (in_trainId, in_carId);
    exception
        when no_data_found then
            raise_application_error(-90095, 'Train of given name or Carriage of given code do not exist.');
    end addCarriageToTrain;

    procedure addLocomotiveToTrain(
        in_name Train.name%type,
        in_code Locomotive.code%type
    ) is
        in_trainId Train.id%type;
        in_carId Car.id%type; 
    begin
        select id into in_trainId from Train where name=in_name;
        select id into in_carId from Locomotive where code=in_code;

        insert into TrainRecipe(trainId, carId) values (in_trainId, in_carId);
    exception
        when no_data_found then
            raise_application_error(-90095, 'Train of given name or Locomotive of given code do not exist.');
    end addLocomotiveToTrain;

    procedure removeCarriageFromTrain(
        in_name Train.name%type,
        in_code Carriage.code%type
    ) is
        in_trainId Train.id%type;
        in_carId Car.id%type;
    begin
        select id into in_trainId from Train where name=in_name;
        select id into in_carId from Carriage where code=in_code;

        delete from TrainRecipe where trainId=in_trainId and carId=in_carId;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Train of given name or Carraige of given code do not exist.');
    end removeCarriageFromTrain;

    procedure removeLocomotiveFromTrain(
        in_name Train.name%type,
        in_code Locomotive.code%type
    ) is
        in_trainId Train.id%type;
        in_carId Car.id%type;
    begin
        select id into in_trainId from Train where name=in_name;
        select id into in_carId from Locomotive where code=in_code;

        delete from TrainRecipe where trainId=in_trainId and carId=in_carId;
    exception
        when no_data_found then
            raise_application_error(-90095, 'Train of given name or Carraige of given code do not exist.');
    end removeLocomotiveFromTrain;
end TrainUI;
/

----TRAIN_LOGIC TRIGGERS----

--LICENSE TRIGGERS
--check if the deleted license is not required by some locomotives
create or replace trigger License_Del_Trigger
before delete on License
for each row
declare
    locomotives_count number := 0;
begin
    select count(*) into locomotives_count from Locomotive where licenseId=:old.id;

    if locomotives_count != 0 then
        raise_application_error(-20100, 'License can not be deleted when it is required by some locomotives.');
    end if;
end;
/

-- sequence for licenseIds
create sequence Seq_licenseId start with 1 increment by 1;

--inserts to LicenseId with automatic id
create or replace trigger License_Ins_Trigger
before insert on License
for each row
begin
    select Seq_licenseId.nextval into :new.id from Dual;
end;
/

--CARGO TRIGGERS
-- check if the deleted cargoType is not used anywhere else
create or replace trigger Cargo_Del_Trigger
before delete on CargoType
for each row
declare
    station_count number := 0;
    car_count number := 0;
begin
    select count(*) into station_count from Station where cargoTypeId=:old.id;
    select count(*) into car_count from Carriage where cargoTypeId=:old.id;

    if (station_count != 0 or car_count != 0) then
        raise_application_error(-20100, 'CargoType can not be deleted when it is used by stations or railway cars.');
    end if;
end;
/

--sequence for  cargoIds
create sequence Seq_cargoId start with 1 increment by 1;

--trigger that creates automatic id's for Cargotypes
create or replace trigger Cargo_Ins_Trigger
before insert on CargoType
for each row
begin
    select Seq_cargoId.nextval into :new.id from Dual;
end;
/

--TRAIN TRIGGERS
--sequence for generating trainIds
create sequence Seq_trainId start with 1 increment by 1;

create or replace trigger Train_Ins_Trigger
before insert on Train
for each row
begin
    select Seq_trainId.nextval into :new.id from Dual;
end;
/

--CAR TRIGGERS
create or replace trigger Car_Ins_Del_Trigger
before insert or delete on Car
begin
    if not TrainUI.fromProcedure then
        raise_application_error(-90090, 'Operations for table Car are prohibited, use defined procedures instead.');
    end if;
end;
/

create sequence Seq_carId start with 1  increment by 1;

/*
abort inserts that are not triggered from procedures and
if insert is from procedure, then create new_id and insert default row into Car table
*/
create or replace trigger Carriage_Ins_Trigger
before insert on Carriage
for each row
declare
    new_id integer;
begin
    if not TrainUI.fromProcedure then
        raise_application_error(-90090, 'Inserting into table Carriage is prohibited, use defined procedures instead.');
    else
        select Seq_carId.nextval into new_id from Dual;

        insert into Car(id, brand, model, weight) values (new_id, 'DEFAULT', 'DEFAULT', 1);

        :new.id := new_id;
    end if;
end;
/

-- abort deletes that are not from procedure
create or replace trigger Carriage_Del_Trigger
before delete on Carriage
begin
    if not TrainUI.fromProcedure then
        raise_application_error(-90090, 'Deleteing from table Carriage is prohibited, use defined procedures instead.');
    end if;
end;
/

/*
abort inserts that are not triggered from procedures and
if insert is from procedure, then create new_id and insert default row into Car table
*/
create or replace trigger Locomotive_Ins_Trigger
before insert on Locomotive
for each row
declare
    new_id integer;
begin
    if not TrainUI.fromProcedure then
        raise_application_error(-90090, 'Inserting into table Locomotive is prohibited, use defined procedures instead.');
    else
        select Seq_carId.nextval into new_id from Dual;

        insert into Car(id, brand, model, weight) values (new_id, 'DEFAULT', 'DEFAULT', 1);

        :new.id := new_id;
    end if;
end;
/

-- abort deletes that are not from procedure
create or replace trigger Locomotive_Del_Trigger
before delete on Locomotive
begin
    if not TrainUI.fromProcedure then
        raise_application_error(-90090, 'Deleteing from table Locomotive is prohibited, use defined procedures instead.');
    end if;
end;
/

--TRAIN RECIPE
/*
checks if Carriage is not used somewhere else and
if train have enough power to work after new carrige is connected
*/
create or replace trigger TrainRecipe_Ins_Trigger
before insert on TrainRecipe
for each row
declare
    car_count integer := 0;
    weight_score Car.weight%type;
begin
    select count(*) into car_count from TrainRecipe where carId=:new.carId;

    if car_count > 0 then
        raise_application_error(-90085, 'This car is already connected to some train.');
    end if;

    TrainUI.fromTrigger := true;
    weight_score := TrainUI.getWeightScoreOfTrainWithNewCar(:new.trainId, :new.carId);
    TrainUI.fromTrigger := false;

    if weight_score > 0 then
        raise_application_error(-90080, 'Train will be overweighted so this car can not be connected.');
    end if;
end;
/

--checks if all Carriages are deleted to delete Train
create or replace trigger TrainRecipe_Del_Trigger
after delete on TrainRecipe
for each row
declare
    car_count integer := 0;
begin
    select count(*) into car_count from TrainRecipe where trainId=:old.trainId;

    if car_count = 0 then
        delete from Train where id=:old.trainId;
    end if;
end;
/

--abort updates on TrainRecipe
create or replace trigger TrainRecipe_Upd_Trigger
before update on TrainRecipe
begin
    raise_application_error(-90090, 'Updates are prohibited for table TrainRecipe.');
end;
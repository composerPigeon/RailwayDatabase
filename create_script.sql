------PLACE_LOGIC TABLES------
create table Place(
    id integer
        constraint Place_PK primary key
);

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
    cargoType varchar2(50) default('pasažéři') not null,
    cargoCapacity number
        constraint Station_cargoCap_gt0 check(cargoCapacity > 0),
    capacityUnit varchar2(10) default('os.') not null
);

------PLACE_LOGIC PKG------
create or replace package PlaceUI as
    childDeletes boolean := false;
    parentInserts boolean := false;

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
        in_cargoType Station.cargoType%type,
        in_cargoCapacity Station.cargoCapacity%type,
        in_capacityUnit Station.capacityUnit%type
    );
    procedure removeStation(
        in_name Station.name%type
    );
end PlaceUI;
/

create or replace package body PlaceUI as
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
    begin
        parentInserts := true;
        insert into Station(name, trainCapacity, cargoCapacity)
            values (in_name, in_trainCapacity, in_cargoCapacity);
        parentInserts := false;
    end addPassangerStation;

    procedure addStation(
        in_name Station.name%type,
        in_trainCapacity Station.trainCapacity%type,
        in_cargoType Station.cargoType%type,
        in_cargoCapacity Station.cargoCapacity%type,
        in_capacityUnit Station.capacityUnit%type
    ) is
    begin
        parentInserts := true;
        insert into Station(name, trainCapacity, cargoType, cargoCapacity, capacityUnit)
            values(in_name, in_trainCapacity, in_cargoType, in_cargoCapacity, in_capacityUnit);
        parentInserts := false;
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
    v_count number := 0;
begin
    select count(*) into v_count from Train where placeId=:old.id;

    if v_count != 0 then
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
before delete on Track
begin
    if not PlaceUI.childDeletes then
        raise_application_error(-20090, 'Deletes are prohibited for table Track');
    end if;
end;
/


------TRAIN_LOGIC TABLES------

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

create table Car (
    id integer
        constraint Car_id_PK primary key,
    brand varchar2(50) not null,
    model varchar2(50) not null,
    maxSpeed number
        constraint Car_maxSpeed_gt0 check(maxSpeed > 0),
    maxWeight number
        constraint Car_maxWeight_gt0 check(maxWeight > 0)
);

create table Carriage (
    id integer
        constraint Carriage_id_PK primary key
        constraint Carriage_id_FK_Car
            references Car(id)
            on delete cascade,
    cargoType varchar2(50) default('passangers') not null,
    capacity number
        constraint Carriage_cap_gt0 check(capacity > 0),
    capacityUnit varchar2(10) default('p.') not null
);

create table License (
    id integer
        constraint License_id_PK primary key,
    description varchar2(50 char)
);

create table Locomotive (
    id integer
        constraint Locomotive_id_PK primary key
        constraint Locomotive_id_FK_Car
            references Car(id)
            on delete cascade,
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


-------EMPLOYEE_LOGIC TABLES--------

create table Employee (
    id integer
        constraint Employee_id_PK primary key,
    name varchar2(50) not null,
    email varchar2(50) not null
        constraint Employee_email_Unique unique,
    phone number(9, 0) not null
);

create table TrainDriver (
    id integer
        constraint TrainDriver_id_PK primary key
        constraint TrainDriver_id_FK_Employee
            references Employee(id)
            on delete cascade
);

create table HasLicense (
    licenseId integer
        constraint HasLicense_licenseId_FK_License
            references License(id)
            on delete cascade,
    driverId integer
        constraint HasLicense_driverId_FK_TrainDriver
            references TrainDriver(id)
            on delete cascade,
    constraint HasLicense_PK primary key (licenseId, driverId)
);

create index HasLicense_licenseId_Inx on HasLicense(licenseId);
create index HasLicense_driverId_Inx on HasLicense(driverId);

create table Drives (
    driverId integer
        constraint Drives_driverId_FK_TrainDriver
            references TrainDriver(id)
            on delete cascade,
    locomotiveId integer
        constraint Drives_locomotiveId_FK_Locomotive
            references Locomotive(id)
            on delete cascade,
    constraint Drives_PK primary key (driverId, locomotiveId)
);

create index Drives_driverId_Inx on Drives(driverId);
create index Drives_trainId_Inx on Drives(locomotiveId);
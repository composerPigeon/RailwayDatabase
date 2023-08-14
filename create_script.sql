---------PLACE_LOGIC TABLES----------

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
    speedLimit number(3, 0)
        constraint Track_speedLimit_gt0 check(speedLimit > 0),
    numOfRails number(1, 0) not null,
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
    trainCapacity number not null
        constraint Station_trainCap_gt0 check(trainCapacity > 0),
    cargoType varchar2(50) default('passengers') not null,
    cargoCapacity number
        constraint Carriage_cap_gt0 check(cargoCapacity > 0),
    capacityUnit varchar2(10) default('p.') not null
);

---------TRAIN_LOGIC TABLES----------

--needs trigger when place is deleted (dont want to delete trains at a station)
create table Train(
    id integer
        constraint Train_id_PK primary key,
    name varchar2(50 char) not null,
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
    weightCapacity numeric
        constraint Locomotive_weightCapacity_gt0 check(weightCapacity > 0),
    licenseId character(4)
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
    trainId integer
        constraint Drives_trainId_FK_Train
            references Train(id)
            on delete cascade,
    constraint Drives_PK primary key (driverId, trainId)
);
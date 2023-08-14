---------PLACE_LOGIC TABLES----------

create table Place(
    id numeric
        constraint Place_PK primary key
);

create table Track(
    id numeric
        constraint Track_id_PK primary key
        constraint Track_id_FK_Place
            references Place(id)
            on delete cascade,
    code character(6) not null
        constraint Track_code_Unique unique,
    length numeric(5, 0)
        constraint Track_length_gt0 check(length > 0),
    speedLimit numeric(3, 0)
        constraint Track_speedLimit_gt0 check(speedLimit > 0),
    numOfRails numeric(1, 0) not null,
        constraint Track_numOfRails_gt0 check(numOfRails > 0)
);

create table Station(
    id numeric 
        constraint Station_id_PK primary key
        constraint Station_id_FK_Place
            references Place(id)
            on delete cascade,
    name varchar2(50 char) not null
        constraint Station_name_Unique unique,
    trainCapacity numeric not null
        constraint Station_trainCap_gt0 check(trainCapacity > 0),
    cargoType varchar2(50) default "passengers" not null,
    capacity numeric
        constraint Carriage_cap_gt0 check(capacity > 0),
    capacityUnit varchar2(10) default "passanger" not null
);

---------TRAIN_LOGIC TABLES----------

--needs trigger when place is deleted (dont want to delete trains at a station)
create table Train(
    id numeric
        constraint Train_id_PK primary key,
    name varchar2(50 char) not null,
        constraint Train_name_Unique unique,
    placeId numeric not null
        constraint Train_placeId_FK_Place
            references Place(id)
);

create index Train_placeId_Inx on Train(placeId);

create table Car (
    id numeric
        constraint Car_id_PK primary key,
    brand varchar2(50) not null,
    model varchar2(50) not null,
    maxSpeed numeric
        constraint Car_maxSpeed_gt0 check(maxSpeed > 0),
    maxWeight numeric
        constraint Car_maxWeight_gt0 check(maxWeight > 0)
);

create table Carriage (
    id numeric
        constraint Carriage_id_PK primary key
        constraint Carriage_id_FK_Car
            references Car(id)
            on delete cascade,
    cargoType varchar2(50) default "passangers" not null,
    capacity numeric
        constraint Carriage_cap_gt0 check(capacity > 0),
    capacityUnit varchar2(10) "passanger" not null
);

create table License (
    id numeric
        constraint License_id_PK primary key,
    description varchar2(50 char)
);

create table Locomotive (
    id numeric
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
    trainId numeric
        constraint TrainRecipe_trainId_FK_Train
            references Train(id)
            on delete cascade,
    carId numeric
        constraint TrainRecipe_carId_FK_Car
            references Car(id)
            on delete cascade,
    constraint TrainRecipe_PK primary key (trainId, carId)
);

create index TrainRecipe_trainId_Inx on TrainRecipe(trainId);
create index TrainRecipe_carId_Inx on TrainRecipe(carId);


-------EMPLOYEE_LOGIC TABLES--------

create table Employee (
    id numeric
        constraint Employee_id_PK primary key,
    name varchar2(50) not null,
    email varchar2(50) not null
        constraint Employee_email_Unique unique,
    phone numeric not null
);

create table TrainDriver (
    id numeric
        constraint TrainDriver_id_PK primary key
        constraint TrainDriver_id_FK_Employee
            references Employee(id)
            on delete cascade
);

create table HasLicense (
    licenseId numeric
        constraint HasLicense_licenseId_FK_License
            references License(id)
            on delete cascade,
    driverId numeric
        constraint HasLicense_driverId_FK_TrainDriver
            references TrainDriver(id)
            on delete cascade,
    constraint HasLicense_PK primary key (licenseId, driverId)
);

create index HasLicense_licenseId_Inx on HasLicense(licenseId);
create index HasLicense_driverId_Inx on HasLicense(driverId);
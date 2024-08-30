# Database application for railway system
This application serves as a database for railway infrastructure. Main usage of this application is managing trains, stations and tracks. It's possible to move trains between tracks and places. Trains can be built from different type of carriages, which user can specify. Whole script `create_schema.sql` is separated into two main parts, first manages the logic of places and second manages the train logic.

## Places
This part of application consists of tables Place, Station and Track, where tables Station and Track inherit after the Place table which contains only field `id`. This part is responsible for creating instances of stations and tracks. It's also responsible for checking integrity constraints.

Tables Train and CargoType are also defined in this part of application because of their dependency on tables from Places section, but most of their functionality is defined in second part.

## Trains
It consists of tables Car, Carriage, Locomotive, TrainRecipe and License. Car contains general infromation about railway cars, which are afterwards inherited by Carriage and Locomotive tables. This part is responsible for managing railway vehicles and trains, which are composed of these.

For more infromation about implementation see `README_cz.md` or the code itself.
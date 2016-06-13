\echo ------------------------
\echo Starting schema creation
\echo ------------------------

begin;

create schema network;

-- This is graphical network edges

create table network.edge(
  id_edge integer,
  name varchar(5),
  friction_se double precision,
  friction_es double precision,
  geom geometry(LINESTRING, 25830));

alter table network.edge
add constraint edge_pkey
primary key(id_edge);

create index edge_geom_gist
on network.edge
using gist(geom);


-- Nodes

create table network.node(
  id_node integer,
  cardinality integer,
  geom geometry(POINT, 25830));

alter table network.node
add constraint node_pkey
primary key(id_node);

create index node_geom_gist
on network.node
using gist(geom);

alter table network.node
add constraint node_geom_unique
unique(geom);


-- Turns

create table network.turn(
  id_node integer,
  id_edge_exit integer,
  id_edge_entry integer,
  friction double precision);

alter table network.turn
add constraint turn_pkey
primary key(id_node, id_edge_exit, id_edge_entry);


commit;


\echo -------------------
\echo End schema creation
\echo -------------------

-- This are the nodes that configures turnings

create table network.edge_end(
  gid_edge integer,
  travel_dir boolean);   -- true: from start to end, false: from end to start

alter table network.edge_end
add constraint edge_end_pkey
primary key(gid_edge, travel_dir);


-- This are the turns allowed between ends

create table network.turn(
  gid_edge_origin integer,
  travel_dir_origin boolean,
  gid_edge_dest integer,
  travel_dir_dest boolean);

alter table network.turn
add constraint turn_pkey
primary key(gid_edge_origin, travel_dir_origin, gid_edge_dest, travel_dir_dest);

-- Foreign keys

alter table network.edge_end
add constraint edge_edge_end_fkey
foreign key (gid_edge) references network.edge(gid);

alter table network.turn
add constraint edge_end_turn_origin_fkey
foreign key(gid_edge_origin, travel_dir_origin) references network.edge_end(gid_edge, travel_dir);

alter table network.turn
add constraint edge_end_turn_dest_fkey
foreign key(gid_edge_dest, travel_dir_dest) references network.edge_end(gid_edge, travel_dir);

-- Error schema

begin;

create schema error;

-- Loops: edges whose start and end points are the same

create or replace view error.topoerror_loop as
select
  *
from
  network.edge
where
  st_startpoint(geom)=st_endpoint(geom);


-- Pseudonodes: nodes with cardinality 2

create or replace view error.topoerror_pseudo as
select
  *
from
  network.node
where
  cardinality=2;


-- Intersections points: points where edge intersects and there is no node

create or replace view error.topoerror_intersectpoint as
with inter_point as(
  select
    a.id_edge as aid_edge,
    b.id_edge as bid_edge,
    (st_dump(st_intersection(a.geom, b.geom))).geom as inter
  from
    network.edge a inner join
    network.edge b on
    st_intersects(a.geom, b.geom) and
    a.id_edge<b.id_edge)
select
  row_number() over () as gid,
  a.aid_edge,
  a.bid_edge,
  inter as geom
from
  inter_point a left join
  network.node b on
  a.inter=b.geom
where
  b.geom is null and st_geometrytype(inter)='ST_Point'; 


-- Node touch interior of edge

create or replace view error.topoerror_nodetouchinterior as
with n as (
  select
    a.id_node,
    b.id_edge,
    st_intersection(a.geom, b.geom)=st_startpoint(b.geom) as onstart,
    st_intersection(a.geom, b.geom)=st_endpoint(b.geom) as onend,
    st_intersection(a.geom, b.geom) as geom
  from
    network.node a inner join
    network.edge b on
    st_intersects(a.geom, b.geom))
select
  row_number() over () as gid,
  *
from
  n
where
  not onstart and not onend;


-- Edge without frictions

create or replace view error.dataerror_edgenofrictions as
select
  *
from
  network.edge
where
  friction_se is null and friction_es is null;


-- Edge with invalid frictions

create or replace view error.dataerror_edgebadfrictions as
select
  *
from
  network.edge
where
  friction_se<0 and friction_es<0;

commit;

/*

  Network visualization

*/

-- This function computes turns at nodes

create or replace function nt__recomputeturns()
returns void as
$$
declare
  _r record;
  _n integer;
begin

  -- Delete existing impossible turns
  for _r in
    with n as (
      select
        a.id_node,
        b.id_edge as id_edge_exit,
        st_startpoint(b.geom)=a.geom as startpoint_exit,
        st_endpoint(b.geom)=a.geom as endpoint_exit,
        b.friction_se as friction_se_exit,
        b.friction_es as friction_es_exit,
        c.id_edge as id_edge_entry,
        st_startpoint(c.geom)=a.geom as startpoint_entry,
        st_endpoint(c.geom)=a.geom as endpoint_entry,
        c.friction_se as friction_se_entry,
        c.friction_es as friction_es_entry
      from
        network.node a inner join
        network.edge b on
        st_intersects(a.geom, b.geom) inner join
        network.edge c on
        st_intersects(a.geom, c.geom)),
    validturns as (
      select *
      from n
      where
        not(
	  (startpoint_exit is true and friction_es_exit is null) or
          (endpoint_exit is true and friction_se_exit is null) or
          (startpoint_entry is true and friction_se_entry is null) or
          (endpoint_entry is true and friction_es_entry is null)))
    select *
    from
      network.turn a left join
      validturns b on
      a.id_node=b.id_node and a.id_edge_exit=b.id_edge_exit and
      a.id_edge_entry=b.id_edge_entry
    where
      b.id_node is null
  loop
    raise warning 'Droping illegal turn at node %, exit edge %, entry edge %',
      _r.id_node, _r.id_edge_exit, _r.id_edge_entry;

    delete from network.turn
    where id_node=_r.id_node and id_edge_exit=_r.id_edge_exit and id_edge_entry=_r.id_edge_entry;
  end loop;

  -- Check possible turns
  for _r in
    with n as (
      select
        a.id_node,
        b.id_edge as id_edge_exit,
        st_startpoint(b.geom)=a.geom as startpoint_exit,
        st_endpoint(b.geom)=a.geom as endpoint_exit,
        b.friction_se as friction_se_exit,
        b.friction_es as friction_es_exit,
        c.id_edge as id_edge_entry,
        st_startpoint(c.geom)=a.geom as startpoint_entry,
        st_endpoint(c.geom)=a.geom as endpoint_entry,
        c.friction_se as friction_se_entry,
        c.friction_es as friction_es_entry
      from
        network.node a inner join
        network.edge b on
        st_intersects(a.geom, b.geom) inner join
        network.edge c on
        st_intersects(a.geom, c.geom))
    select *
    from n
    where
      not(
	  (startpoint_exit is true and friction_es_exit is null) or
        (endpoint_exit is true and friction_se_exit is null) or
        (startpoint_entry is true and friction_se_entry is null) or
        (endpoint_entry is true and friction_es_entry is null))
    order by
      id_node, id_edge_exit, id_edge_entry
   loop
     -- Check if turn already exists
     select into _n count(*) from network.turn
     where id_node=_r.id_node and id_edge_exit=_r.id_edge_exit and id_edge_entry=_r.id_edge_entry;

     if _n=0 then
          insert into network.turn values(_r.id_node, _r.id_edge_exit, _r.id_edge_entry, null);
	       
	  raise warning 'Identified new possible turn at node %, exit edge %, entry node %',
     	  	_r.id_node, _r.id_edge_exit, _r.id_edge_entry;
     end if;
   end loop;

end;
$$
language plpgsql;



-- This function recomputes all existing nodes and add them to the node
-- table if they weren't present

create or replace function nt__recomputenodes()
returns void as
$$
declare
  _r record;
  _nid integer;
  _n integer;
begin 

  -- Get next id for potential new nodes

  select into _nid max(id_node) from network.node;

  if _nid is null then
    _nid = 1;
  else
    _nid = _nid+1;
  end if;

  -- Delete nodes that doesn't still exists any more

  for _r in 
    with newnodes as(
      select
        st_startpoint(geom) as geom
      from
        network.edge
      union
      select
        st_endpoint(geom) as geom
      from
        network.edge)
    select
      a.id_node, a.geom
    from
      network.node a left join
      newnodes b on
      a.geom=b.geom
    where
      b.geom is null
    order by a.id_node
  loop
    raise warning 'Deleted not existing node with ID %: %', _r.id_node, st_asewkt(_r.geom);
    
    delete from network.node where id_node=_r.id_node;
  end loop;

  -- Add new nodes

  for _r in
    with points as(
      select
        st_startpoint(geom) as geom
      from
        network.edge
      union
      select
        st_endpoint(geom) as geom
      from
        network.edge)
    select
      a.geom
    from
      points a left join
      network.node b on
      a.geom=b.geom
    where
      b.geom is null
  loop
    -- Add new node
    insert into network.node(id_node, geom) values(_nid, _r.geom);
    
    raise warning 'Found new node with new ID %: %', _nid, st_asewkt(_r.geom);
    
    _nid = _nid+1;
  end loop;

  -- Update node cardinality
  
  for _r in
    with newnodes as(
      select
        st_startpoint(geom) as geom
      from
        network.edge
      union all
      select
        st_endpoint(geom) as geom
      from
        network.edge),
    n as(
      select
        a.id_node,
        count(*) as n,
        a.geom
      from
        network.node a inner join
        newnodes b on
        a.geom=b.geom
      group by
        a.id_node, a.geom)
    select
      *
    from
      network.node a inner join
      n on
      a.id_node=n.id_node
    where
      n.n<>a.cardinality or a.cardinality is null
    order by a.id_node
  loop
    raise warning 'Cardinality changed to % for node ID %: %', _r.n, _r.id_node, st_asewkt(_r.geom);

    update network.node set cardinality=_r.n where id_node=_r.id_node;
  end loop;


end;
$$
language plpgsql;


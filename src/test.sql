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
      validturns
    where id_edge_exit=5;

/*

  Exporting network data.

*/

\echo -------------------------------
\echo Starting export of network data
\echo -------------------------------

\c networkx postgres

begin;

\copy network.edge to 'csv/edge.csv' with delimiter '|' csv header quote '"' encoding 'utf-8' null '-'

\copy network.node to 'csv/node.csv' with delimiter '|' csv header quote '"' encoding 'utf-8' null '-'

\copy network.turn to 'csv/turn.csv' with delimiter '|' csv header quote '"' encoding 'utf-8' null '-'

commit;



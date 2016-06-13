/*

  Importing network data.

*/

\echo -------------------------------
\echo Starting export of network data
\echo -------------------------------

\c network postgres

begin;

\copy network.edge from 'csv/edge.csv' with delimiter '|' csv header quote '"' encoding 'utf-8' null '-'

\copy network.node from 'csv/node.csv' with delimiter '|' csv header quote '"' encoding 'utf-8' null '-'

\copy network.turn from 'csv/turn.csv' with delimiter '|' csv header quote '"' encoding 'utf-8' null '-'

commit;



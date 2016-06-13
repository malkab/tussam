/*

  Deletion of network database.

*/

\echo --------------------------
\echo Starting database deletion
\echo --------------------------

\c postgres postgres

drop database network;

\echo ---------------------
\echo End database deletion
\echo ---------------------

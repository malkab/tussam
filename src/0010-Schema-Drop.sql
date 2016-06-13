/*

  Deletion of network schema.

*/

\echo ------------------------
\echo Starting schema deletion
\echo ------------------------

\c network postgres

drop schema network cascade;

\echo -------------------
\echo End schema deletion
\echo -------------------

/*

  Creation of a test schema database for traffic network analysis.

*/

\echo ------------------------
\echo Create database creation
\echo ------------------------

\c postgres postgres

create database network;

\c network postgres

create extension postgis;


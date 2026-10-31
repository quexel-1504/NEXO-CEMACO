SET DEFINE OFF
/* =============================================================================
   OPCIONAL - Permiso para el "monitor de bloqueos" del Laboratorio web
   -----------------------------------------------------------------------------
   Permite que el usuario CEMACO lea V$SESSION (quién espera a quién).
   Sin este permiso la aplicación funciona igual; solo no muestra la tabla
   del monitor dentro de la prueba Cyber Days.

   Ejecutar en una terminal (CMD):
       sqlplus / as sysdba
       @"C:\ruta\24_permisos_monitor.sql"
   ============================================================================= */

ALTER SESSION SET CONTAINER = XEPDB1;

GRANT SELECT ON sys.v_$session TO cemaco;

SELECT grantee, table_name, privilege
  FROM dba_tab_privs
 WHERE grantee = 'CEMACO' AND table_name = 'V_$SESSION';

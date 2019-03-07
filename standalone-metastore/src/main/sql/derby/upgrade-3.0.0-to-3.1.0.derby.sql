-- Upgrade MetaStore schema from 3.0.0 to 3.1.0
-- HIVE-19440
ALTER TABLE "APP"."GLOBAL_PRIVS" ADD "AUTHORIZER" VARCHAR(128);
DROP INDEX "APP"."GLOBALPRIVILEGEINDEX";
CREATE UNIQUE INDEX "APP"."GLOBALPRIVILEGEINDEX" ON "APP"."GLOBAL_PRIVS" ("AUTHORIZER", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "USER_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "APP"."DB_PRIVS" ADD "AUTHORIZER" VARCHAR(128);
DROP INDEX "APP"."DBPRIVILEGEINDEX";
CREATE UNIQUE INDEX "APP"."DBPRIVILEGEINDEX" ON "APP"."DB_PRIVS" ("AUTHORIZER", "DB_ID", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "DB_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "APP"."TBL_PRIVS" ADD "AUTHORIZER" VARCHAR(128);
DROP INDEX "APP"."TABLEPRIVILEGEINDEX";
CREATE INDEX "APP"."TABLEPRIVILEGEINDEX" ON "APP"."TBL_PRIVS" ("AUTHORIZER", "TBL_ID", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "TBL_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "APP"."PART_PRIVS" ADD "AUTHORIZER" VARCHAR(128);
DROP INDEX "APP"."PARTPRIVILEGEINDEX";
CREATE INDEX "APP"."PARTPRIVILEGEINDEX" ON "APP"."PART_PRIVS" ("AUTHORIZER", "PART_ID", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "PART_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "APP"."TBL_COL_PRIVS" ADD "AUTHORIZER" VARCHAR(128);
DROP INDEX "APP"."TABLECOLUMNPRIVILEGEINDEX";
CREATE INDEX "APP"."TABLECOLUMNPRIVILEGEINDEX" ON "APP"."TBL_COL_PRIVS" ("AUTHORIZER", "TBL_ID", "COLUMN_NAME", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "TBL_COL_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "APP"."PART_COL_PRIVS" ADD "AUTHORIZER" VARCHAR(128);
DROP INDEX "APP"."PARTITIONCOLUMNPRIVILEGEINDEX";
CREATE INDEX "APP"."PARTITIONCOLUMNPRIVILEGEINDEX" ON "APP"."PART_COL_PRIVS" ("AUTHORIZER", "PART_ID", "COLUMN_NAME", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "PART_COL_PRIV", "GRANTOR", "GRANTOR_TYPE");

CREATE INDEX "APP"."TAB_COL_STATS_IDX" ON "APP"."TAB_COL_STATS" ("CAT_NAME", "DB_NAME", "TABLE_NAME", "COLUMN_NAME");

-- HIVE-19340
ALTER TABLE TXNS ADD COLUMN TXN_TYPE integer;

-- HIVE-19027
-- add column MATERIALIZATION_TIME (bigint) to MV_CREATION_METADATA table
ALTER TABLE "APP"."MV_CREATION_METADATA" ADD COLUMN "MATERIALIZATION_TIME" BIGINT;
UPDATE "APP"."MV_CREATION_METADATA" SET "MATERIALIZATION_TIME" = 0;
ALTER TABLE "APP"."MV_CREATION_METADATA" ALTER COLUMN "MATERIALIZATION_TIME" NOT NULL;

-- add column CTC_UPDATE_DELETE (char) to COMPLETED_TXN_COMPONENTS table
ALTER TABLE COMPLETED_TXN_COMPONENTS ADD COLUMN CTC_UPDATE_DELETE char(1);
UPDATE COMPLETED_TXN_COMPONENTS SET CTC_UPDATE_DELETE = 'N';
ALTER TABLE COMPLETED_TXN_COMPONENTS ALTER COLUMN CTC_UPDATE_DELETE NOT NULL;

CREATE TABLE MATERIALIZATION_REBUILD_LOCKS (
  MRL_TXN_ID BIGINT NOT NULL,
  MRL_DB_NAME VARCHAR(128) NOT NULL,
  MRL_TBL_NAME VARCHAR(256) NOT NULL,
  MRL_LAST_HEARTBEAT BIGINT NOT NULL,
  PRIMARY KEY(MRL_TXN_ID)
);

-- HIVE-19416
ALTER TABLE "APP"."TBLS" ADD COLUMN "WRITE_ID" BIGINT DEFAULT 0;
ALTER TABLE "APP"."PARTITIONS" ADD COLUMN "WRITE_ID" BIGINT DEFAULT 0;

-- HIVE-19267
CREATE TABLE TXN_WRITE_NOTIFICATION_LOG (
  WNL_ID bigint NOT NULL,
  WNL_TXNID bigint NOT NULL,
  WNL_WRITEID bigint NOT NULL,
  WNL_DATABASE varchar(128) NOT NULL,
  WNL_TABLE varchar(128) NOT NULL,
  WNL_PARTITION varchar(767) NOT NULL,
  WNL_TABLE_OBJ clob NOT NULL,
  WNL_PARTITION_OBJ clob,
  WNL_FILES clob,
  WNL_EVENT_TIME integer NOT NULL,
  PRIMARY KEY (WNL_TXNID, WNL_DATABASE, WNL_TABLE, WNL_PARTITION)
);
INSERT INTO SEQUENCE_TABLE (SEQUENCE_NAME, NEXT_VAL) VALUES ('org.apache.hadoop.hive.metastore.model.MTxnWriteNotificationLog', 1);

-- HIVE-20221: change PARTITION_PARAMS.PARAM_VALUE to CLOB
ALTER TABLE "APP"."PARTITION_PARAMS" ADD COLUMN "PARAM_VALUE_CLOB" CLOB;
UPDATE "APP"."PARTITION_PARAMS" SET PARAM_VALUE_CLOB=CAST(PARAM_VALUE AS CLOB);
ALTER TABLE "APP"."PARTITION_PARAMS" DROP COLUMN PARAM_VALUE;
RENAME COLUMN "APP"."PARTITION_PARAMS"."PARAM_VALUE_CLOB" TO "PARAM_VALUE";

-- This needs to be the last thing done.  Insert any changes above this line.
UPDATE "APP".VERSION SET SCHEMA_VERSION='3.1.0', VERSION_COMMENT='Hive release version 3.1.0' where VER_ID=1;

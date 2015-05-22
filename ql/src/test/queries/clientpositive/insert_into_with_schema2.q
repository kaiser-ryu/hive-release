-- SORT_QUERY_RESULTS;

set hive.enforce.bucketing=true;

create table studenttab10k (age2 int);
insert into studenttab10k values(1);

create table student_acid (age int, grade int)
 clustered by (age) into 1 buckets;

insert into student_acid(age) select * from studenttab10k;

select * from student_acid;

insert into student_acid(grade, age) select 3 g, * from studenttab10k;

select * from student_acid;

insert into student_acid(grade, age) values(20, 2);

insert into student_acid(age) values(22);

select * from student_acid;

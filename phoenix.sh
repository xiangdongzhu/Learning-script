#!/bin/bash

#获取当前时间
time=$(date "+%Y-%m-%d %H:%M:%S")
echo $time
echo $time >> zxd_phoenix.log

#将SQL语句，查询插入时间为最大的值赋给变量flag
flag=`hive -e "
--不打印字段名称
set hive.cli.print.header=false;
select max(insert_time) from ods.t_position_phoenix"| grep -v "WARN"`

#显示最大插入时间
echo ${flag}
echo ${flag} >> zxd_phoenix.log

#获取最大插入时间，并将大于这个时间的数据插入Phoenix映射表
hive -e "insert into table ods.t_position_phoenix select * from ods.t_position where insert_time>'${flag}';"

#获取最大时间参数，并生成Phoenix可执行SQL文件 /opt/zxd/phoenix.sql
echo "upsert into DM_COMPAY_PHOENIX select NEXT VALUE FOR DM_COMPAY_SEQUENCE,"\"com_fullname"\","\"p_name"\","\"salary_month"\","\"salary_min"\","\"salary_max"\","\"province"\","\"city"\","\"county"\","\"address"\","\"edu_require"\","\"exp_require"\","\"source"\","\"update_time"\","\"statement"\" fr
om T_POSITION_PHOENIX where "\"insert_time"\">'${flag}';" >/opt/zxd/phoenix.sql

#将最新时间更新到DM_COMPAY_PHOENIX 职位数据表
/usr/bin/phoenix-sqlline.py lienidata001 /opt/zxd/phoenix.sql > $(date "+%Y-%m-%d").txt
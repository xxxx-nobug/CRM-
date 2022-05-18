/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2020/3/5 9:12:54                             */
/*==============================================================*/


drop table if exists tbl_dic_type;

drop table if exists tbl_dic_value;

/*==============================================================*/
/* Table: tbl_dic_type                                          */
/*==============================================================*/
create table tbl_dic_type
(
   code                 varchar(255) not null comment '����������������Ϊ�գ����ܺ������ġ�',
   name                 varchar(255),
   description          varchar(255),
   primary key (code)
);

/*==============================================================*/
/* Table: tbl_dic_value                                         */
/*==============================================================*/
create table tbl_dic_value
(
   id                   char(32) not null comment '����������UUID',
   value                varchar(255) comment '����Ϊ�գ�����Ҫ��ͬһ���ֵ��������ֵ�ֵ�����ظ�������Ψһ�ԡ�',
   text                 varchar(255) comment '����Ϊ��',
   order_no             varchar(255) comment '����Ϊ�գ�����Ϊ�յ�ʱ��Ҫ�������������',
   type_code            varchar(255) comment '���',
   primary key (id)
);


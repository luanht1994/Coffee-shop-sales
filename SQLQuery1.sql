create database	luandb;

create table news(
	tieu_de nvarchar(30),
	noi_dung nvarchar (200),
	media varchar (30),
	ngay date,
	chuyen_muc_id int,
	primary key (tieu_de),
	foreign key (chuyen_muc_id) references chuyenmuc(chuyen_muc_id)
);

create table chuyenmuc (
	chuyen_muc_id int,
	ten_chuyen_muc nvarchar (30),
	primary key (chuyen_muc_id)
);
insert into chuyenmuc (chuyen_muc_id,ten_chuyen_muc)
values (1, 'bongda');

update chuyenmuc
set ten_chuyen_muc = 'bongda-1' , chuyen_muc_id = 3
where chuyen_muc_id = 3;

delete from chuyenmuc where chuyen_muc_id = 3;

select * from chuyenmuc;

drop table news;

alter table news
	add hinh_anh nvarchar(30);
alter table news
	drop column hinh_anh;
alter table news 
	alter column tieu_de nvarchar(100);
drop database luandb;
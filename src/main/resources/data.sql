-- noinspection SqlResolveForFile
insert into movies (id, title, year, director)
select nextval('movies_seq'), 'The Shawshank Redemption', 1994, 'Frank Darabont'
where not exists (select 1 from movies where title = 'The Shawshank Redemption');

insert into movies (id, title, year, director)
select nextval('movies_seq'), 'The Godfather', 1972, 'Francis Ford Coppola'
where not exists (select 1 from movies where title = 'The Godfather');

insert into movies (id, title, year, director)
select nextval('movies_seq'), 'The Dark Knight', 2008, 'Christopher Nolan'
where not exists (select 1 from movies where title = 'The Dark Knight');

insert into movies (id, title, year, director)
select nextval('movies_seq'), 'The Godfather Part II', 1974, 'Francis Ford Coppola'
where not exists (select 1 from movies where title = 'The Godfather Part II');

insert into movies (id, title, year, director)
select nextval('movies_seq'), '12 Angry Men', 1957, 'Sidney Lumet'
where not exists (select 1 from movies where title = '12 Angry Men');
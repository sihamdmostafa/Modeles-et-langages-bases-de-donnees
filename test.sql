-- UE SAM 2021

-- NOM :
 
--Prénom : 


-- =========================
--      TME Index 2021
-- =========================

-- vider la corbeille
purge recyclebin;


-- Le format par défaut d'une date 
alter session set NLS_DATE_FORMAT='DD/MM/YYYY';
SELECT SYS_CONTEXT ('USERENV', 'NLS_DATE_FORMAT') as format_date_par_defaut FROM DUAL;

--select sysdate from dual;

--desc tpch.Lineitem;


--Q1 

select table_name, blocks, num_rows, avg_row_len, global_stats, user_stats
from all_tables
where owner = upper('tpch') and not(table_name like 'S%')
order by num_rows desc;


create or replace synonym LINEITEM for tpch.LINEITEM;
create or replace synonym ORDERS for tpch.ORDERS;
create or replace synonym PARTSUPP for tpch.PARTSUPP;
create or replace synonym PART for tpch.PART;
create or replace synonym CUSTOMER for tpch.CUSTOMER;
create or replace synonym NATION for tpch.NATION;
create or replace synonym REGION for tpch.REGION;

--Q2

drop table Commande cascade constraints purge;
create table Commande (
    numCde Number not null,
    numClient Number not null,
    etat Char(1) not null,
    prix Number(15,2) not null,
    dateC Date not null,
    priorite Char(15) not null,
    vendeur Char(15) not null,
    commentaire Varchar2(100)
);


insert into Commande (
select
    o_orderkey as numCde,
    o_custkey as numClient,
    o_orderstatus as etat,
    o_totalprice as prix,
    o_orderdate as dateC,
    o_orderpriority as priorite, o_clerk as vendeur,
    o_comment as commentaire from Orders
where extract(year from o_orderdate) = 1992
and extract(month from o_orderdate) between 1 and 3
);

--Q3

drop table AchatProduit cascade constraints purge;
create table AchatProduit (
    numCde Number not null,
    numAchat Number not null,
    dateAchat Date not null,
    prix Number(15,2) not null,
    quantite Number(15,2) not null,
    numProduit Number not null,
    numFournisseur Number not null,
    commentaire varchar2(100)
);

insert into AchatProduit (
select
    l_orderkey as numCde,
    l_linenumber as numAchat,
    l_receiptdate as dateAchat,
    l_extendedprice as prix,
    l_quantity as quantite,
    l_partkey as numProduit, 
    l_suppkey as numFournisseur,
    l_comment as commentaire from LineItem
    where l_orderkey in (select numCde from Commande)
);

--Q4



drop table Client cascade constraints purge;
create table Client (
    numClient Number not null,
    nom varchar2(25) not null,
    numPays Number(22) not null,
    segment character(10) not null,
    commentaire varchar2(117)
);

insert into Client (
select
    c_custkey as numClient,
    c_name as nom,
    c_nationkey as numPays,
    c_mktsegment as segment,
    c_comment as commentaire from Customer
    where c_custkey in (select numClient from Commande)
);



drop table Produit cascade constraints purge;
create table Produit (
    numProduit Number not null,
    nom varchar2(55) not null,
    marque character(10) not null,
    typeP varchar(25) not null,
    taille number(22) not null,
    prixDetail number(22)
);

insert into Produit (
select
    p_partkey as numProduit,
    p_name as nom,
    p_brand as marque,
    p_type as typeP,
    p_size as taille, 
    p_retailprice as prixDetail from Part
    where p_partkey in (select numProduit from AchatProduit)
);


--Q5

create or replace procedure analyse(nomTable varchar2) as
utilisateur varchar2(30);
begin
select sys_context('USERENV', 'SESSION_USER') into utilisateur from dual;
-- avec histogramme:
-- dbms_stats.gather_table_stats(utilisateur, upper(nomTable));
-- SANS histogramme :
dbms_stats.gather_table_stats(utilisateur, upper(nomTable), method_opt=>'for all columns size 1');
end;
/
show error




exec analyse('Commande');
exec analyse('AchatProduit');
exec analyse('Client');
exec analyse('Produit');



select table_name, column_name, data_type, num_distinct,
avg_col_len as longueur_moyenne,
utl_raw.cast_to_number(low_value) as borneInf,
utl_raw.cast_to_number(high_value) AS borneSup,
density
from user_tab_columns c
where data_type = 'NUMBER'
order by table_name, column_id;


select table_name, column_name, data_type, num_distinct,
avg_col_len as longueur_moyenne,
utl_raw.cast_to_varchar2(low_value) as borneInf,
utl_raw.cast_to_varchar2(high_value) AS borneSup,
density
from user_tab_columns c
where data_type like '%CHAR%'
order by table_name, column_id;


select table_name, column_name, data_type, num_distinct,
avg_col_len as longueur_moyenne,
utl_raw.cast_to_varchar2(low_value) as borneInf,
utl_raw.cast_to_varchar2(high_value) AS borneSup,
density
from user_tab_columns c
where data_type like 'DATE' and table_name = 'COMMANDE'
order by table_name, column_id;


select table_name, column_name, data_type, num_distinct,
avg_col_len as longueur_moyenne,
utl_raw.cast_to_varchar2(low_value) as borneInf,
utl_raw.cast_to_varchar2(high_value) AS borneSup,
density
from user_tab_columns c
where column_name = 'PRIX' and table_name = 'COMMANDE'
order by table_name, column_id;





select table_name, column_name, data_type, num_distinct,
avg_col_len as longueur_moyenne,
utl_raw.cast_to_varchar2(low_value) as borneInf,
utl_raw.cast_to_varchar2(high_value) AS borneSup,
density
from user_tab_columns c
where column_name = 'QUANTITE' and table_name = 'ACHATPRODUIT'
order by table_name, column_id;



--Q6

--création de l'index sur l'attribut quantite
drop index I_Achat_quantite;
create index I_Achat_quantite on AchatProduit(quantite);

--création de l'index sur l'attribut prix
drop index I_Achat_prix;
create index I_Achat_prix on AchatProduit(prix);

--création de l'index sur l'attribut numAchat
drop index I_Achat_numAchat;
create index I_Achat_numAchat on AchatProduit(numAchat);

--création de l'index sur l'attribut numCde
drop index I_Achat_numCde;
create index I_Achat_numCde on AchatProduit(numCde);

--création de l'index sur l'attribut dateAchat
drop index I_Achat_dateAchat;
create index I_Achat_dateAchat on AchatProduit(dateAchat);

--création de l'index sur l'attribut numProduit
drop index I_Achat_numProduit;
create index I_Achat_numProduit on AchatProduit(numProduit);

--création de l'index sur l'attribut numFournisseur
drop index I_Achat_numFournisseur;
create index I_Achat_numFournisseur on AchatProduit(numFournisseur);

--création de l'index sur l'attribut commentaire
drop index I_Achat_commentaire;
create index I_Achat_commentaire on AchatProduit(commentaire);


SELECT index_name as nom,
 index_type as type_index,
 blevel as profondeur,
 distinct_keys as nb_valeurs_distinctes,
 num_rows as nb_rowids,
 leaf_blocks as nb_pages_de_rowids,
 uniqueness as unicite,
 clustering_factor as CF
FROM user_indexes;



SELECT /*+ index(a I_achat_prix) */
*
FROM AchatProduit a
WHERE prix < 2000;

SELECT /* index(a I_achat_quantite) */
 *
FROM AchatProduit a
WHERE quantite > 40;

SELECT /*+ index(a I_achat_prix) */
 prix
FROM AchatProduit a;

/
select /*+ index(a I_achat_prix) */
numAchat,numCde
from AchatProduit a
WHERE quantite > 40 and prix < 2000 ; 
/
SELECT /*+ index_join(a I_achat_prix I_achat_quantite) */
 numCde, numAchat
FROM AchatProduit a
WHERE prix < 2000 and quantite > 40;


--Q6

drop index I_Achat_quantite;
create index I_Achat_quantite on AchatProduit(quantite);

drop index I_Achat_prix;
create index I_Achat_prix on AchatProduit(prix);

drop index I_Achat_numAchat;
create index I_Achat_numAchat on AchatProduit(numAchat);

drop index I_Achat_numCde;
create index I_Achat_numCde on AchatProduit(numCde);

drop index I_Achat_dateAchat;
create index I_Achat_dateAchat on AchatProduit(dateAchat);

drop index I_Achat_numProduit;
create index I_Achat_numProduit on AchatProduit(numProduit);

drop index I_Achat_numFournisseur;
create index I_Achat_numFournisseur on AchatProduit(numFournisseur);

drop index I_Achat_commentaire;
create index I_Achat_commentaire on AchatProduit(commentaire);




SELECT index_name as nom,
 index_type as type_index,
 blevel as profondeur,
 distinct_keys as nb_valeurs_distinctes,
 num_rows as nb_rowids,
 leaf_blocks as nb_pages_de_rowids,
 uniqueness as unicite,
 clustering_factor as CF
FROM user_indexes
where index_name like 'I%';

/

SELECT /*+ index(a I_Achat_quantite_prix) */
 numCde, numAchat
FROM AchatProduit a
WHERE prix < 1000 and quantite = 2;

SELECT /*+ index(a I_Achat_quantite_prix) */
 numCde, numAchat
FROM AchatProduit a
WHERE quantite = 2;

SELECT /*+ index(a I_Achat_quantite_prix) */
 numCde, numAchat
FROM AchatProduit a
WHERE prix > 1000;


SELECT /*+ index(a I_Achat_quantite_prix) */
 numCde, numAchat
FROM AchatProduit a
WHERE prix < 1000;
--Q9 
SELECT index_name as nom,
 index_type as type_index,
 blevel as profondeur,
 num_rows,
 leaf_blocks as nb_pages_de_rowids
FROM user_indexes;
--Cost_Index_Range_Scan(n) = blevel + n * leaf_blocks / num_rows


/*
a- Cost_Index_Range_Scan(2400) = 1 + 2400 * 532 / 226736
b- Cost_Index_Range_Scan(46273) = 1 + 46273 * 443 / 226736
c- Cost_Index_Range_Scan(226736) = 1 + 226736 * 532 / 226736
d- Cost_Index_Range_Scan(46273) = 1 + 46273 * 443 / 226736
d- Cost_Index_Range_Scan(2400) = 1 + 2400 * 532 / 226736
e- ???????????

 */ 
--Q10

SELECT index_name as nom,
 num_rows,
 clustering_factor as CF
FROM user_indexes;

--Cost_table_Access_By_Rowid(n) = Cost_Index_Range_Scan(n) + n * CF / num_rows


/*
a- Cost_table_Access_By_Rowid(2400) = Cost_Index_Range_Scan(n) + 2400 * 226627 / 226736
b- Cost_table_Access_By_Rowid(46273) = Cost_Index_Range_Scan(n) + 46273 * 93286 / 226736
c- Cost_table_Access_By_Rowid(226736) = Cost_Index_Range_Scan(n) + 226736 * 226627 / 226736
d- Cost_table_Access_By_Rowid(46273) = Cost_Index_Range_Scan(n) + 490 * 93286 / 226736
d- Cost_table_Access_By_Rowid(2400) = Cost_Index_Range_Scan(n) + 490 * 226627 / 226736
e- 
*/ 
 
--Q11

SELECT *
FROM AchatProduit a
WHERE prix between 2000 and 4000 ;

select utl_raw.cast_to_number(low_value) as borneInf,
 utl_raw.cast_to_number(high_value) as borneSup
from user_tab_columns
where table_name = upper('AchatProduit')
and column_name = upper('prix');

select num_rows as num
from user_tables
where table_name = upper('AchatProduit');

/* 
cardSelection('AchatProduit','prix',2000,4000)=(4000-2000)/(104449.5-904)*22673
*/

/

create or replace function cardSelection(T varchar2,ATT varchar2,v1 number,v2 number) as
begin
select utl_raw.cast_to_number(low_value) as borneInf,
 utl_raw.cast_to_number(high_value) as borneSup
from user_tab_columns
where table_name = upper(T)
and column_name = upper(ATT);

select num_rows as num
from user_tables
where table_name = upper(T);

return (v2-v1)/(borneSup-borneInf)*num;

end;

/

--Q12

alter table Commande add constraint cle_commande primary key(numCde);

/*Oui la requete déclench la création de l'index CLE_COMMANDE*/
/*Les caractéristiques de cet index est (num_rows est 56741,la profondeur est 1 et nombre de page de rowids est 126))  */
SELECT index_name as nom,
 index_type as type_index,
 blevel as profondeur,
 num_rows,
 leaf_blocks as nb_pages_de_rowids
FROM user_indexes;

--Q13 

select prix
from AchatProduit
order by prix;
/* le cout de l'opération est 535 */ 

select distinct prix
from AchatProduit
order by prix;
/* le cout de l'opération est 144 */

/* l'INDEX FAST FULL SCAN provoque moins de lectures que full scan car avec le fast full scan on itére just les clé de 
l'index (qui sont unique) c'est a dire on commance directement par le feuills de l'arbre or avec 
le full scan on itére les clé avec la list du rowids pour chaque clé */ 

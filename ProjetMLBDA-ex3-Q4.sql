--pour representer l'élement River,on crée le type T_river
create type T_river as object(
Name VARCHAR2(35 Byte),--Contient le nom du River
country VARCHAR2(35 Byte),--Contient la source du river
 member function toXML return XMLType
)
/
create or replace type body T_river as
   member function toXML return XMLType is
   output XMLType;
   begin 
   output := XMLType.createxml('<River name="'||self.name||'" Source="'||self.country||'"></River>');
   return output;
   end;
  end; 
/
create table Lesrivers of T_river;
/
create or replace type T_ensriver as table of T_river;
/
create type T_mondial as object(
id Number,
member function toXML return XMLType
)
/
create or replace type body T_mondial as
   member function toXML return XMLType is
   output XMLType;
   tmpriver T_ensriver ; 
   begin
    output := XMLType.createxml('<mondial></mondial>');
    select value(p) bulk collect into tmpriver
      from Lesrivers p ;
    for indx IN 1..tmpriver.COUNT
      loop
         output := XMLType.appendchildxml(output,'mondial',tmpriver(indx).toXML()); 
      end loop;
     return output;
   end;
 end;
/
create table Lesmond of T_mondial;
/
insert into Lesrivers
  select T_river(c.NAME,p.NAME) 
         from RIVER c,GEO_SOURCE d,Country p
         where c.NAME=d.RIVER and p.code=d.country; 
         

insert into Lesmond values(T_mondial(1));
 



-- exporter le r?sultat dans un fichier 
WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\req4.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/       

select p.toXML().getClobVal() 
from Lesmond p;

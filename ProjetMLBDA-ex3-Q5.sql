   
create or replace  type T_border   as object (
   COUNTRY1         VARCHAR2(4 Byte),
   COUNTRY2         VARCHAR2(4 Byte),
   LENGTH           Number,
   member function toXML return XMLType
)
/
create table lesborder of T_border;
/
create or replace  type T_Pays as object (
   NAME        VARCHAR2(35 Byte),
   CODE        VARCHAR2(4 Byte),
   CAPITAL     VARCHAR2(35 Byte),
   PROVINCE    VARCHAR2(35 Byte),
   AREA        NUMBER,
   POPULATION  NUMBER,
   member function sum_lenght return Number,
   member function toXML return XMLType
)
/
create or replace type body T_Pays as
   member function sum_lenght return Number is 
   leng number; 
   begin
   leng := 0 ;
   select distinct sum(m.LENGTH) as a into leng
      from lesborder m
      where m.COUNTRY1=self.code or m.COUNTRY2=self.code;
   if leng is null then 
      leng := 0 ;
   end if; 
   return leng;
   end; 
   member function toXML return XMLType is
   output XMLType;
   -- V_montagnes T_ensXML;
   begin
      if name is null then 
      output := null ; 
      else
      output := XMLType.createxml('<country name="'||NAME||'"  blength="'||self.sum_lenght()||'"></country>');
      end if; 
      return output;
   end;
end;
/
create or replace type T_enspays as table of T_pays;
/
create table LesPays of T_Pays;
/
create type T_mondial as object(
id Number,
member function toXML return XMLType
)
/
create or replace type body T_mondial as
   member function toXML return XMLType is
   output XMLType;
   tmppays T_enspays ; 
   begin
    output := XMLType.createxml('<mondial></mondial>');
    select value(p) bulk collect into tmppays
      from LesPays p;
    for indx IN 1..tmppays.COUNT
      loop
         output := XMLType.appendchildxml(output,'mondial',tmppays(indx).toXML()); 
      end loop;
     return output;
   end;
 end ;
/
create table Lesmond of T_mondial;
/

insert into Lesmond values(T_mondial(1));

insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;
         

 
insert into lesborder
  select T_border(m.COUNTRY1, m.COUNTRY2,m.LENGTH) 
         from BORDERS m ;   


-- exporter le r?sultat dans un fichier 
WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\req.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from Lesmond m ;

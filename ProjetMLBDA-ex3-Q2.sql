
--on crée ce type pour connaitre les Pays membres de chaque organisation
create type pays_org as object(
 Country        VARCHAR2(4 Byte),
 ORGANIZATION  VARCHAR2(12 Byte),
 member function toXML return XMLType 
) 
/

create table lespays_org of pays_org;
/
--pour représenter l'élément organization on crée le type T_organization
create or replace  type T_organization  as object (
   Abbreviation        VARCHAR2(12 Byte),--contient l'abbreviation de l'organization
   NAME        VARCHAR2(80 Byte),--contient le nom de l'organization 
   ESTABLISHED Date,--contient la date de création de l'organization 
   member function toXML return XMLType -- une méthode pour génrer l'XML de l'élément organization
)
/

create or replace type body T_organization as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément organization a la fin
 
   begin
      if self.name is null or self.ESTABLISHED is null --dans le dtd,name et  Date sont #REQUIRED dans l'élement organization 
      then 
       -- donc si l'un des deux n'existe pas alors on ajoute pas l'élement organization 
      output := null ; 
      else
      output := XMLType.createxml('<organization name="'||self.name||'" Date="'||self.ESTABLISHED||'"/>');   
      end if ;  
      return output;
   end;
end;
/
--on crée le type T_ensorganization pour stocker les objets de type T_organization pour 
--representer l'element organization+ qui existe dans l'élement organization
create or replace type T_ensorganization as table of T_organization;
/
--on crée la table qui contient les objets de type T_organization

create table Lesorganization of T_organization;
/
--pour représenter l'élément country on crée le type T_Pays
create or replace  type T_Pays as object (
   NAME        VARCHAR2(35 Byte),--contient le nom du pays 
   CODE        VARCHAR2(4 Byte),--contient le code du pays
   CAPITAL     VARCHAR2(35 Byte),--contient la capital du pays
   PROVINCE    VARCHAR2(35 Byte),--contient la province du pays 
   AREA        NUMBER,--cntient l'area du pays
   POPULATION  NUMBER,--contient la population du pays 
   member function toXML return XMLType-- une méthode pour génrer l'XML de l'élément country

)
/
create or replace type body T_Pays as  
   member function toXML return XMLType is
   output XMLType;--output contient la structure de l'xml de lélément country
   -- V_montagnes T_ensXML;
   tmporg T_ensorganization;--variable contient un tableau d'objets de type T_organization
   begin
      if self.name is null then --dans l'élément country name est un attribut #REQUIRED 
      --donc si il n'existe pas alors on enlève carrément l'élément country
      output := null ; 
      else 
      output := XMLType.createxml('<country  name="'||self.NAME||'"></country>');
      --on trouve tout les organization au quelle self.name est un member 
      select value(m) bulk collect into tmporg
      from Lesorganization m,lespays_org c 
      where c.ORGANIZATION = m.Abbreviation and c.country=self.code 
      order by m.ESTABLISHED; --on tri les resultat selon la date de création
      for indx IN 1..tmporg.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmporg(indx).toXML());   
      end loop;
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
      from LesPays p ;
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

insert into lespays_org
  select pays_org(m.COUNTRY, m.ORGANIZATION) 
         from ISMEMBER m ; 
  
insert into Lesorganization
  select T_organization(c.ABBREVIATION, c.NAME,c.ESTABLISHED) 
         from ORGANIZATION c;  
    
     
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;

WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\req2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
       
select m.toXML().getClobVal() 
from Lesmond m ;

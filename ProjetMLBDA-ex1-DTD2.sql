--pour représenter l'élément border  on crée le type T_border
create or replace  type T_border   as object (
   COUNTRY1         VARCHAR2(4 Byte),
   COUNTRY2         VARCHAR2(4 Byte),
   LENGTH           Number,-- contient longueur du border
   member function toXML return XMLType -- une méthode pour génrer l'XML de l'élément border
)
/

create or replace type body T_border as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément border a la fin
   begin 
      if self.LENGTH is null --dans le dtd on a l'attribut length est #REQUIRED
       then 
       -- donc si il n'existe pas alors on enlève carrément l'élément border  
        output := null;
       ELSE 
         if self.COUNTRY2 is null--dans le dtd on a l'attribut length est #REQUIRED
          then 
       -- donc si il n'existe pas alors on enlève carrément l'élément border  
          output := null;
           ELSE
             -- sinon,si les deux attributs existe alors on crée l'élément border comme elle définie dans le dtd 
             output := XMLType.createxml('<border countryCode="'||self.COUNTRY2||'" length ="'||self.LENGTH||'"></border>');
         end if ; 
      end if;
      return output;--output contient null ou la structure de l'xml de lélément border
   end;
end;
/
--on crée la table lesborder qui contient les objets de type T_border
create table lesborder of T_border;
/
--pour représenter l'élément language  on crée le type T_language
create or replace  type T_language as object (
   COUNTRY         VARCHAR2(4 Byte),--contient la pays de la langue
   name         VARCHAR2(50 Byte),--contient le nom de la langue
   percentage           Number,
   member function toXML return XMLType-- une méthode pour génrer l'XML de l'élément language
)
/

create or replace type body T_language as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément language a la fin
   begin
     if self.name is null-- l'attribut name est #REQUIRED 
       then 
        --donc si il n'existe pas alors on enlève carrément l'élément language 
        output := null;
       ELSE 
         if self.percentage is null-- l'attribut percentage est #REQUIRED
          then 
          --donc si il n'existe pas alors on enlève carrément l'élément language 
          output := null;
           ELSE
          -- sinon,si les deux attributs existe alors on crée l'élément language comme elle définie dans le dtd 
          output := XMLType.createxml('<language  language ="'||self.name||'" percent  ="'||self.percentage||'"></language>');
          end if;
        end if;
     return output;--donc output contient null ou la structure de l'xml de lélément language 
   end;
end;
/
--on crée la table leslanguage qui contient les objets de type T_language
create table leslanguage of T_language;
/
--pour représenter l'élément country on crée le type T_Pays
create or replace  type T_Pays as object (
   NAME        VARCHAR2(35 Byte),--contient le nom du pays 
   CODE        VARCHAR2(4 Byte),--contient le code du pays
   CAPITAL     VARCHAR2(35 Byte),--contient la capital du pays
   PROVINCE    VARCHAR2(35 Byte),--contient la province du pays 
   AREA        NUMBER,--cntient l'area du pays
   POPULATION  NUMBER,--contient la population du pays 
   member function toXML_borders return XMLType,-- une méthode pour génrer l'XML de l'élément borders 
   member function toXML return XMLType-- une méthode pour génrer l'XML de l'élément country
)
/
--on crée le type T_enslanguage pour stocker les objets de type T_language pour 
--representer l'element language* qui existe dans l'élement country
create or replace type T_enslanguage as table of T_language;
/
--on crée le type T_ensborder pour stocker les objets de type T_border pour 
--representer l'element border* qui existe dans l'élement borders
create or replace type T_ensborder as table of T_border;
/
create or replace type body T_Pays as
   member function toXML_borders return XMLType is
   output XMLType;--variable contient l'XML de l'élément borders a la fin
   tmpbrders T_ensborder;--variable contient un tableau d'objets de type T_border
   begin
      output := XMLType.createxml('<borders/>');
      --on trouve les pays qui est en border avec la pays de code self.code,on stock le resultat dans tmpbrders
      select value(m) bulk collect into tmpbrders
      from lesborder m
      where m.COUNTRY1=self.CODE;
      for indx IN 1..tmpbrders.COUNT
      --avec cette boucle on va créer border* donc pour chaque border de tmpbrders on appele a la methode toxml pour génrer l'XML de l'élément border 
      loop
         output := XMLType.appendchildxml(output,'borders', tmpbrders(indx).toXML());   
      end loop;
      --on fait la meme choose mais avec m.country2=self.code
      select T_Border(m.country2,m.country1,m.LENGTH) bulk collect into tmpbrders
      from lesborder m     
      where m.country2=self.CODE ; 
    for indx IN 1..tmpbrders.COUNT
      loop
         output := XMLType.appendchildxml(output,'borders', tmpbrders(indx).toXML());   
      end loop;
      return output; 
   end;
   member function toXML return XMLType is
   output XMLType;--output contient null ou la structure de l'xml de lélément country
   -- V_montagnes T_ensXML;
   tmplanguage T_enslanguage;--variable contient un tableau d'objets de type T_continent
   begin
     if self.NAME is null--dans l'élément country name est un attribut #REQUIRED 
       then 
       --donc si il n'existe pas alors on enlève carrément l'élément country
        output := null;
       ELSE 
         if self.population is null --dans l'élément country population est un attribut #REQUIRED
          then 
          --donc si il n'existe pas alors on enlève carrément l'élément country
          output := null;
           ELSE
             if self.code is null --dans l'élément country code est un attribut #ILMPLIED
             then 
               --donc si l'attribut n'éxiste pas (null) alors on ne l'ajoute pas a l'xml 
             output := XMLType.createxml('<country name="'||NAME||'"  population="'||population||'"></country>');
             ELSE 
             output := XMLType.createxml('<country code="'||self.code||'" name="'||NAME||'"  population="'||population||'"></country>');
             end if;
       -- on commence par trouvé les langues du pays,on stock le resultat dans tmpMontagne 
      --en utilisant bulk collect into
      select value(m) bulk collect into tmplanguage
      from leslanguage m
      where self.code = m.COUNTRY ;  
     --pour chaque langue de tmplanguage on appele a la methode toxml pour génrer l'XML de l'élément language  
      for indx IN 1..tmplanguage.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmplanguage(indx).toXML());   
      end loop;
         --on ajoute aussi l'élément borders a country en utilisant la méthode toXML_borders
         output := XMLType.appendchildxml(output,'country', toXML_borders);   
        end if ; 
        end if ;  
     return output;
   end;
end;
/

--on crée la table qui contient les objets de type T_Pays
create table LesPays of T_Pays;
/
--on crée ce type pour connaitre Pays membres de chaque organisation
create type T_ismember as object(
COUNTRY    VARCHAR2(4 Byte),--contient le code du pays
Abbreviation        VARCHAR2(12 Byte),--contient l'abbreviation d'une origanisation
type VARCHAR2(35 Byte)--contient le type de l'organisation
)
/

create table Lesmembres of T_ismember;
/
--pour représenter l'élément organization on crée le type T_organization
create or replace  type T_organization1  as object (
   Abbreviation        VARCHAR2(12 Byte),--contient l'abbreviation de l'organisation
   NAME        VARCHAR2(80 Byte),--contient le nom de l'organisation
   CITY     VARCHAR2(35 Byte),--contient la city de l'organisation 
   COUNTRY    VARCHAR2(4 Byte),--contient le headquarter de l'organisation 
   member function toXML return XMLType -- une méthode pour génrer l'XML de l'élément organization
)
/
--on crée le type T_enspays pour stocker les objets de type T_Pays pour 
--representer l'element coutnry+ qui existe dans l'élement organization
create or replace type T_enspays as table of T_Pays;
/
create or replace type body T_organization1 as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément organization a la fin
   -- V_montagnes T_ensXML;
   tmppays T_enspays;--variable contient un tableau d'objets de type T_pays
   begin
       output := XMLType.createxml('<organization/>');
       --on trouve les pays memebe de l'organisation,on stock le resultat dans tmppays
       select value(m) bulk collect into tmppays
       from LesPays m,Lesmembres c
       where c.Abbreviation = self.Abbreviation and m.CODE=c.COUNTRY ;  
       for indx IN 1..tmppays.COUNT
       loop
          --avec cette boucle on va representer country+ donc pour chaque continent de tmppays on appele a la methode toxml pour génrer l'XML de l'élément country 
          output := XMLType.appendchildxml(output,'organization', tmppays(indx).toXML());   
       end loop;
          if self.COUNTRY is not null --dans l'élement headquarter on a l'attribut name est #REQUIRED
          then 
          --donc si il existe alors on ajoute l'élement headquarter dans organization
          output := XMLType.appendchildxml(output,'organization', XMLType('<headquarter name="'||self.COUNTRY||'"></headquarter>'));  
          ELSE 
          --on enleve l'element organization car headquarter n'a pas de name,donc le headquarter ne doit pas étre exister 
          --du coup l'element organization ne doit pas etre exister(<!ELEMENT organization (country+, headquarter) >)
          output := null ; 
          end if ;
    return output;--output contient null ou la structure de l'xml de lélément organization
   end;
end;
/
--pour représenter l'élément mondial on crée le type T_mondial
create or replace  type T_mondial as object (
   id Number,
   member function toXML return XMLType-- une méthode pour génrer l'XML de l'élément mondial
)
/
--on crée le type T_ensorganization pour stocker les objets de type T_organization1 pour 
--representer l'element organization+ qui existe dans l'élement organization
create or replace type T_ensorganization as table of T_organization1;
/
--on crée la table qui contient les objets de type T_organization1
create table Lesorganization of T_organization1;
/
create or replace type body T_mondial as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément mondial a la fin
   tmporganisation T_ensorganization;--variable contient un tableau d'objets de type T_organization1 
   begin
      output := XMLType.createxml('<mondial></mondial>');
      --on trouve tout les organisations,on stock le resultat dans tmporganisation
      select value(m) bulk collect into tmporganisation
      from Lesorganization m;
      for indx IN 1..tmporganisation.COUNT
      --avec cette boucle on va créer organization+ donc pour chaque organization de tmporganisation on appele a la methode toxml pour génrer l'XML de l'élément organization 
      loop
         output := XMLType.appendchildxml(output,'mondial', tmporganisation(indx).toXML());   
      end loop;
      return output;
   end;
end;
/
--on crée la table qui contient les objets de type T_mondial
create table Lesmondial of T_mondial;
/
-- on remplie la table LesPays en utilisant la table COUNTRY de la base de données mondial
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;
         
-- on remplie la table Lesorganization en utilisant la table ORGANIZATION de la base de données mondial
insert into Lesorganization
  select T_organization1(c.ABBREVIATION, c.NAME, c.CITY, 
         c.COUNTRY) 
         from ORGANIZATION c;

-- la table Lesmond contient un seul objet
INSERT INTO Lesmondial (id)
 VALUES (1);
 
-- on remplie la table leslanguage en utilisant la table LANGUAGE de la base de données mondial

insert into  leslanguage
  select T_language(m.COUNTRY, m.NAME, m.PERCENTAGE) 
         from LANGUAGE m;

-- on remplie la table lesborder en utilisant la table BORDERS de la base de données mondial

insert into lesborder
  select T_border(m.COUNTRY1, m.COUNTRY2,m.LENGTH) 
         from BORDERS m ;  

-- on remplie la table Lesmembres en utilisant la table ISMEMBER de la base de données mondial

insert into Lesmembres
  select T_ismember(m.COUNTRY, m.ORGANIZATION,m.TYPE) 
         from ISMEMBER m ;    


WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\exo1_dtd2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from Lesmondial m ;












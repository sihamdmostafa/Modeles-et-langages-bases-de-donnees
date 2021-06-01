set sqlbl on
/
--GEOCOORD est un type qui contient la longitude et l'atitude d'un objet (island,desert,river..) dans 
--le dtd elle est définie comme l'élément coordinates
create type GEOCOORD as object(
latitutde NUMBER,--attribut contient l'atitude 
longitude Number,-- attribut cotient la longitude
member function toXML return XMLType -- une méthode pour génrer l'XML de l'élément coordinates
)
/
create or replace type body GEOCOORD as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément coordinates a la fin
   begin
      if self.latitutde is null -- l'attribut latitude est #REQUIRED 
       then 
        --donc si il n'existe pas alors on enlève carrément l'élément coordinates 
        output := null;
       ELSE 
         if self.longitude is null --l'attribut longitude est #REQUIRED
          then 
          output := null;--donc si il n'existe pas alors on enlève carrément l'élément coordinates 
           ELSE
             -- sinon,si les deux attributs existe alors on crée l'élément cooridinates comme elle définie dans le dtd 
              output := XMLType.createxml('<coordinates  latitude="'||latitutde||'" longitude="'||longitude||'"></coordinates>');
          end if ; 
        end if ; 
       return output;--donc output contient null ou la structure de l'xml de lélément cooridinates
   end;
end;
/
create or replace  type T_island as object (
   name          VARCHAR2(35 Byte),--contient le nom de island
   Islands       VARCHAR2(35 Byte),
   Area          Number,--contient l'area de l'island 
   Height        Number,--contient l'atitude de l'island 
   TypeI         VARCHAR2(10 Byte),--contient le type de l'island
   Country       VARCHAR2(4 Byte),--contient le pays de l'island 
   cord          GEOCOORD,--contient les coordonnes de l'isalnd 
   member function toXML return XMLType -- une méthode pour génrer l'XML de l'élément Island
)
/
create or replace type body T_island as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément Island a la fin
   begin
      if self.name is null --dans le dtd on voit que l'attribut name est #REQUIRED 
       then 
         --donc si il n'existe pas alors on enlève carrément l'élément island
         output:= null;
       else
        -- sinon,si les deux attributs existe alors on crée l'élément island comme elle définie dans le dtd 
        output := XMLType.createxml('<island name="'||self.name||'"></island>');
        --dans l'élément isalnd on trouve l'élément coordinates donc 
        output := XMLType.appendchildxml(output,'island',cord.toXML());
      end if ; 
      return output;--donc output contient null ou la structure de l'xml de l'élément island 
   end;
end;
/
--on crée la table qui contient les objets de type T_island
create table LesIslands of T_island ;
/
create or replace  type T_desert   as object (
   name          VARCHAR2(35 Byte),--contient le nom de la desert 
   area          Number,--contient l'area de la desert 
   Country     VARCHAR2(4 Byte),--contient le pays de la desert
   member function toXML return XMLType-- une méthode pour génrer l'XML de l'élément desert
)
/
create or replace type body T_desert as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément desert a la fin
   begin
   if self.area is null -- l'attribut area est #IMPLIED donc l'élément desert 
       then 
       --donc si il n'existe pas alors on l'ajoute pas dans l'élément
        output := XMLType.createxml('<desert name="'||name||'"></desert>');
       ELSE 
        output := XMLType.createxml('<desert name="'||name||'" area="'||area||'"></desert>');
        end if ; 
       if self.name is null--l'attribut name est #REQUIRED 
       then 
        --donc si il n'existe pas alors on enlève carrément l'élément desert 
        output := null ;
       end if ; 
       return output;
   end;
end;
/
--on crée la table qui contient les objets de type T_desert
create table Lesdesert of T_desert ;
/
create or replace  type T_Montagne as object (   
   NAME         VARCHAR2(35 Byte),--contient le nom de la montagne
   MOUNTAINS    VARCHAR2(35 Byte),
   HEIGHT       NUMBER,--contient latitude de la montagne
   TYPE         VARCHAR2(10 Byte),--contient le type de la montagne
   CODEPAYS      VARCHAR2(4),--contient le pays ou il existe la montagne
   member function toXML return XMLType -- une méthode pour génrer l'XML de l'élément mountain
)
/

create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élémment mountain a la fin
   begin
     if self.name is null--dans on le dtd on l'attribut name et HEIGHT de lélément continent sont #REQUIRED
      --donc si l'un des deux attributs n'existe pas alors on enlève carrément l'élément mountain 
       then 
        output := null;
       ELSE 
         if self.HEIGHT is null
          then 
          output := null;
           ELSE
          -- sinon,si les deux attributs existe alors on crée l'élément mountain comme elle définie dans le dtd 
          output := XMLType.createxml('<mountain name="'||self.name||'" height="'||self.HEIGHT||'"></mountain>');
          end if ; 
        end if ;
      return output;--donc output contient null ou la structure de l'xml de l'élément mountain
   end;
end;


/
--on crée la table qui contient les objets de type T_Montagne
create table LesMontagnes of T_Montagne;
/
--pour représenter l'élément country on crée le type T_Pays
create or replace  type T_Pays as object (
 NAME        VARCHAR2(35 Byte),--contient le nom du pays 
   CODE        VARCHAR2(4 Byte),--contient le code du pays
   CAPITAL     VARCHAR2(35 Byte),--contient la capital du pays
   PROVINCE    VARCHAR2(35 Byte),--contient la province du pays 
   AREA        NUMBER,--cntient l'area du pays
   POPULATION  NUMBER,--contient la population du pays 
   member function toXML return XMLType,-- une méthode pour génrer l'XML de l'élément country
   member function geoXML return XMLType,-- une méthode pour génrer l'XML de l'élément geo
   member function haut return Number-- une méthode pour donner la hauteur de la plus haute montagne d'une pays
)
/
--on crée le type T_ensisland pour stocker les objets de type T_island pour 
--representer l'element island qui existe dans l'élement geo
create or replace type T_ensisland as table of T_island;
/
--on cree le type T_ensdesert pour stocker les objets de type T_desert pour 
--representer l'element desert qui existe dans l'élement geo
create or replace type T_ensdesert as table of T_desert;
/
--on crée le type T_ensMontagne pour stocker les objets de type T_Montagne pour 
--representer l'element mountain qui existe dans l'élement geo
create or replace type T_ensmontagne as table of T_Montagne;
/
--on crée la table qui contient les objets de type T_Pays
create table LesPays of T_Pays;
/
create or replace type body T_Pays as
   member function haut return Number is
   val Number;--contient la hauteur de la plus haute montagne du pays
   begin
   val :=0;--on initialise val a 0
   --on trouve la hauteur de la plus haute montagne du pays
   select max(m.HEIGHT) into val
      from LesMontagnes m
      where self.Code = m.CODEPAYS ;
   -- if montagne n'existe pas alors val est 0 
   if val is null 
   then 
     val := 0;
   end if ; 
   return val;
   end;
    member function geoXML return XMLType is
    output XMLType;--variable contient l'XML de l'élément geo
    tmpisland T_ensisland;--variable contient un tableau d'objets de type T_island
    tmpmontagne T_ensmontagne;--variable contient un tableau d'objets de type T_Montagne
    tmpdesert T_ensdesert;--variable contient un tableau d'objets de type T_desert
    begin
    output := XMLType.createxml('<geo></geo>');--on crée l'élément geo
     -- on commence par trouvé les islands du pays,on stock le resultat dans tmpisland 
     --en utilisant bulk collect into
      select value(m) bulk collect into tmpisland
      from LesIslands m
      where self.Code = m.Country ;  
       --on trouve les montagnes du pays,on stock le resultat dans tmpmontagne 
      select value(m) bulk collect into tmpmontagne
      from LesMontagnes m
      where self.Code = m.CODEPAYS ;
      --on trouve les desert du pays,on stock le resultat dans tmpdesert 
      select value(m) bulk collect into tmpdesert
      from Lesdesert m
      where self.Code = m.Country ;
      for indx IN 1..tmpmontagne.COUNT
      loop
         --pour chaque montagne de tmpMontagne on appele a la methode toxml pour génrer l'XML de l'élément mountain 
         output := XMLType.appendchildxml(output,'geo', tmpmontagne(indx).toXML());   
      end loop;
      for indx IN 1..tmpdesert.COUNT
      --pour chaque desert de tmpdesert on appele a la methode toxml pour génrer l'XML de l'élément desert 
      loop
         output := XMLType.appendchildxml(output,'geo', tmpdesert(indx).toXML());   
      end loop;
      for indx IN 1..tmpisland.COUNT
      --pour chaque island de tmpisland on appele a la methode toxml pour génrer l'XML de l'élément island 
      loop
         output := XMLType.appendchildxml(output,'geo', tmpisland(indx).toXML());   
      end loop;
      return output;
    end;
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément country a la fin
   nom VARCHAR2(35 Byte) ;
   begin
     if self.name is null --dans l'élément country name est un attribut #REQUIRED 
      then 
      --donc si il n'existe pas alors on enlève carrément l'élément country
      output := null;
     ELSE  
        --si non on crée l'élement country comme indiquer dans le DTD
        output := XMLType.createxml('<country  name="'||name||'" ></country>');
        --on ajoute a country l'élement geo en utilisant la méthode geoXML
        output := XMLType.appendchildxml(output,'country ',geoXML);
        if self.haut()!=0 --si self.haut()!=0  alors la montagne la plus haute existe 
        then
         --on trouve le nom du montagne la plus haut
          select distinct m.name into nom
            from LesMontagnes m
            where m.HEIGHT=self.haut() and self.Code = m.CODEPAYS;
           --on ajoute a l'élement country l'élement peak 
          output := XMLType.appendchildxml(output,'country', XMLType('<peak name="'||nom||'"></peak>'));
       end if ;
      end if;
      return output;
   end;
end;
/
--pour représenter l'élément ex2 on crée le type ex2
create type ex2 as object(
id Number,
member function toXML return XMLType
)
/
--on crée le type T_enspays pour stocker les objets de type T_pays 
create or replace type T_enspays2 as table of T_pays;
/
create or replace type body ex2 as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'élément ex2 a la fin
   tmppays T_enspays2 ;--variable contient un tableau d'objets de type T_pays
   begin
    --on crée l'objet ex2
    output := XMLType.createxml('<ex2></ex2>');
   --on trouve tout les pays,on stock le resultat dans tmppays
    select value(p) bulk collect into tmppays
      from LesPays p ;
    for indx IN 1..tmppays.COUNT
   --avec cette boucle on va créer country+ donc pour chaque pays de tmppays on appele a la methode toxml pour génrer l'XML de l'élément country 
      loop
         output := XMLType.appendchildxml(output,'ex2',tmppays(indx).toXML()); 
      end loop;
     return output;
   end;
 end ;
/
--on crée la table ex21 qui contient les objets de type ex2
create table ex21 of ex2;
/
-- on remplie la table LesPays en utilisant la table COUNTRY de la base de données mondial
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;
-- la table ex21 contient un seul objet        
insert into ex21 values(ex2(1));
-- on remplie la table LesMontagnes en utilisant la table GEO_MOUNTAIN (pour trouver le pays 
--de la montagne)et MOUNTAIN de la base de données mondial                            
insert into  LesMontagnes
  select T_Montagne(m.name, m.mountains, m.height, 
         m.type, g.country) 
         from MOUNTAIN m, GEO_MOUNTAIN g
         where g.MOUNTAIN=m.NAME;
-- on remplie la table Lesdesert en utilisant la table GEO_DESERT (pour trouver le pays 
--du desert)et DESERT de la base de données mondial 
insert into Lesdesert
  select T_desert(m.name, m.area,g.COUNTRY) 
         from DESERT m,GEO_DESERT g
         where g.DESERT=m.NAME;
-- on remplie la table LesIslands en utilisant la table GEO_ISLAND (pour trouver le pays 
--de l'island)et ISLAND de la base de données mondial           
         
insert into LesIslands
  select T_island(m.name, m.islands,m.area,m.height,m.type,g.COUNTRY,GEOCOORD(m.COORDINATES.latitude,m.COORDINATES.longitude)) 
         from ISLAND m,GEO_ISLAND g
         where g.ISLAND=m.NAME;
  



-- exporter le r?sultat dans un fichier 
WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\exo2_partie1.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select p.toXML().getClobVal() 
from ex21 p;

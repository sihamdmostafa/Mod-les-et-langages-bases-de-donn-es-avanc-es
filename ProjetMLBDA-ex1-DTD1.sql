set sqlbl on
/
--pour repr�senter l'�l�ment airport on cr�e le type T_airport
create or replace  type T_airport as object (
   NAME         VARCHAR2(100 Byte),--contient le nom de l'airport 
   city     VARCHAR2(50 Byte),--contient la city de l'airport 
   Country  VARCHAR2(4 Byte),--contient la ville de l'airport
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment airport
)
/
create or replace type body T_airport as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment airport a la fin
   begin
       if self.city is null --dans le dtd on a l'attribut nearcity est #IMPLIED
       then 
        --donc si l'attribut n'�xiste pas (null) alors on ne l'ajoute pas a l'xml 
        output := XMLType.createxml('<airport name="'||NAME||'"></airport>');
       ELSE 
        -- sinon si il existe alors on l'ajoute a l'ensemble des attributs 
        output := XMLType.createxml('<airport name="'||NAME||'" nearCity ="'||city||'"></airport>');
        end if ; 
        --l'attribut name est #REQUIRED 
       if self.name is null 
       then 
        -- donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment airport  
        output := null ;
       end if ; 
       return output; --donc output contient null ou la structure de l'xml de l�l�ment airport 
   end;
end;
/
--on cr�e la table qui contient les objets de type T_airport
create table Lesairports of T_airport;
/
-- GEOCOORD est un type qui contient la longitude et l'atitude d'un objet (island,desert,river..) dans 
--le dtd elle est d�finie comme l'�l�ment coordinates
create type GEOCOORD as object(
latitutde NUMBER,--attribut contient l'atitude 
longitude Number,-- attribut cotient la longitude
member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment coordinates
)
/
create or replace type body GEOCOORD as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment coordinates a la fin
   begin
      if self.latitutde is null -- l'attribut latitude est #REQUIRED 
       then 
        --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment coordinates 
        output := null;
       ELSE 
         if self.longitude is null --l'attribut longitude est #REQUIRED
          then 
          output := null;--donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment coordinates 
           ELSE
             -- sinon,si les deux attributs existe alors on cr�e l'�l�ment cooridinates comme elle d�finie dans le dtd 
              output := XMLType.createxml('<coordinates  latitude="'||latitutde||'" longitude="'||longitude||'"></coordinates>');
          end if ; 
        end if ; 
       return output;--donc output contient null ou la structure de l'xml de l�l�ment cooridinates
   end;
end;
/
--pour repr�senter l'�l�ment island on cr�e le type T_island
create or replace  type T_island as object (
   name          VARCHAR2(35 Byte),--contient le nom de island
   Islands       VARCHAR2(35 Byte),
   Area          Number,--contient l'area de l'island 
   Height        Number,--contient l'atitude de l'island 
   TypeI         VARCHAR2(10 Byte),--contient le type de l'island
   Country       VARCHAR2(4 Byte),--contient le pays de l'island 
   cord          GEOCOORD,--contient les coordonnes de l'isalnd 
   Province    VARCHAR2(35 Byte),--contient la province de l'isalnd 
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment Island
)
/
create or replace type body T_island as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment Island a la fin
   begin
      if self.name is null --dans le dtd on voit que l'attribut name est #REQUIRED 
       then 
         --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment island
         output:= null;
       else
        -- sinon,si les deux attributs existe alors on cr�e l'�l�ment island comme elle d�finie dans le dtd 
        output := XMLType.createxml('<island name="'||self.name||'"></island>');
        --dans l'�l�ment isalnd on trouve l'�l�ment coordinates donc 
        output := XMLType.appendchildxml(output,'island',cord.toXML());
      end if ; 
      return output;--donc output contient null ou la structure de l'xml de l�l�ment island 
   end;
end;
/
--on cr�e la table qui contient les objets de type T_island
create table LesIslands of T_island ;
/
--pour repr�senter l'�l�ment continent on cr�e le type T_continent
create or replace  type T_continent  as object (
   name          VARCHAR2(20 Byte),--contient le nom de la continent
   country    VARCHAR2(4 Byte),--contient les pays qui existe dans la continent qui est representer par name 
   parcent        Number(10),--contient le pourcentage du pays (country) dans la continent (name) 
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment continent
)
/
create or replace type body T_continent as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment continent a la fin
   begin
      if self.name is null--dans on le dtd on l'attribut name de l�l�ment continent est #REQUIRED  
       then 
        --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment continent 
        output := null;
       ELSE 
         if self.parcent is null--dans on le dtd on l'attribut name de l�l�ment continent est #REQUIRED
          then 
          --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment continent 
          output := null;
           ELSE
             -- sinon,si les deux attributs existe alors on cr�e l'�l�ment continent comme elle d�finie dans le dtd 
             output := XMLType.createxml('<continent name="'||self.name||'" percent="'||self.parcent||'"></continent>');
          end if ; 
        end if ;
      return output;--output contient null ou la structure de l'xml de l�l�ment continent
   end;
end;
/
--on cr�e la table qui contient les objets de type T_continent
create table Lescontinent of T_continent ;
/
create or replace  type T_desert   as object (
   name          VARCHAR2(35 Byte),--contient le nom de la desert 
   area          Number,--contient l'area de la desert 
   Country     VARCHAR2(4 Byte),--contient le pays de la desert
   Province    VARCHAR2(35 Byte),--contient la province de la desert 
   member function toXML return XMLType-- une m�thode pour g�nrer l'XML de l'�l�ment desert
)
/
create or replace type body T_desert as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment desert a la fin
   begin
   if self.area is null -- l'attribut area est #IMPLIED dans l'�l�ment desert 
       then 
       --donc si il n'existe pas alors on l'ajoute pas dans l'�l�ment
        output := XMLType.createxml('<desert name="'||name||'"></desert>');
       ELSE 
        output := XMLType.createxml('<desert name="'||name||'" area="'||area||'"></desert>');
        end if ; 
       if self.name is null--l'attribut name est #REQUIRED 
       then 
        --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment desert 
        output := null ;
       end if ; 
       return output;
   end;
end;
/
--on cr�e la table qui contient les objets de type T_desert
create table Lesdesert of T_desert ;
/


create or replace  type T_Montagne as object (
   NAME         VARCHAR2(35 Byte),--contient le nom de la montagne
   MOUNTAINS    VARCHAR2(35 Byte),
   HEIGHT       NUMBER,--contient latitude de la montagne
   TYPE         VARCHAR2(10 Byte),--contient le type de la montagne
   CODEPAYS      VARCHAR2(4),--contient le pays ou il existe la montagne
   Province    VARCHAR2(35 Byte),--contient la province de la montagne
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment mountain
)
/
create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�mment mountain a la fin
   begin
     if self.name is null--dans on le dtd on l'attribut name et HEIGHT de l�l�ment continent sont #REQUIRED
      --donc si l'un des deux attributs n'existe pas alors on enl�ve carr�ment l'�l�ment mountain 
       then 
        output := null;
       ELSE 
         if self.HEIGHT is null
          then 
          output := null;
           ELSE
          -- sinon,si les deux attributs existe alors on cr�e l'�l�ment mountain comme elle d�finie dans le dtd 
          output := XMLType.createxml('<mountain name="'||self.name||'" height="'||self.HEIGHT||'"></mountain>');
          end if ; 
        end if ;
      return output;--donc output contient null ou la structure de l'xml de l'�l�ment mountain
   end;
end;
/
--on cr�e la table qui contient les objets de type T_Montagne
create table LesMontagnes of T_Montagne;
/
--pour repr�senter l'�l�ment province on cr�e le type T_provinc
create or replace  type T_provinc as object (
   NAME         VARCHAR2(35 Byte),--contient le nom de la province
   Country    VARCHAR2(4 Byte),--contient le pays de la province
   Population       NUMBER,--contient la population de la province
   Area         NUMBER,--contient l'area de la province
   Capital         VARCHAR2(35 Byte),--contient la capitale de la province
   CapProv  VARCHAR2(35 Byte),
   member function toXML return XMLType-- une m�thode pour g�nrer l'XML de l'�l�ment province
)
/
--on cr�e le type T_ensMontagne pour stocker les objets de type T_Montagne pour 
--representer l'element mountain qui existe dans l'�lement province
create or replace type T_ensMontagne as table of T_Montagne;
/
--on cree le type T_ensdesert pour stocker les objets de type T_desert pour 
--representer l'element desert qui existe dans l'�lement province
create or replace type T_ensdesert as table of T_desert;
/
--on cr�e le type T_ensisland pour stocker les objets de type T_island pour 
--representer l'element island qui existfe dans l'�lement province
create or replace type T_ensisland  as table of T_island ;
/
create or replace type body T_provinc as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment province a la fin
   -- V_montagnes T_ensXML;
   tmpMontagne T_ensMontagne;--variable contient un tableau d'objets de type T_Montagne 
   tmpdesert T_ensdesert;--variable contient un tableau d'objets de type T_desert 
   tmpisland T_ensisland;--variable contient un tableau d'objets de type T_island 
   begin
     if self.name is null--dans  le dtd on a l'attribut name de l�l�ment province est #REQUIRED  
       then  
       --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment province 
        output := null;
       ELSE 
         if self.Capital is null --dans  le dtd on a l'attribut name de l�l�ment province est #REQUIRED
          then 
          --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment province 
          output := null;
          ELSE
          -- sinon,si les deux attributs existe alors on cr�e l'�l�ment province comme elle d�finie dans le dtd 
          output := XMLType.createxml('<province name="'||name||'" capital="'||Capital||'"></province>');
          --pour la representation de (mountain|desert)* j'ai choisi de le representer de la forme suivant 
          --mountain mountain mountain mountain mountain mountain.....desert desert desert desert desert desert desert
          -- on commence par trouv� les montagnes de la province,on stock le resultat dans tmpMontagne 
          --en utilisant bulk collect into
          select value(m) bulk collect into tmpMontagne
          from LesMontagnes m
           where self.NAME = m.Province ; 
           --on trouve les deserts associ� a la province,on stock le resultat dans tmpdesert 
          select value(m) bulk collect into tmpdesert
          from Lesdesert m
          where self.NAME = m.Province ;
          --on trouve les islands de la province,on stock le resultat dans tmpisland
          select value(m) bulk collect into tmpisland
          from LesIslands m
          where self.NAME = m.Province ;
          for indx IN 1..tmpMontagne.COUNT
            loop
              --pour chaque montagne de tmpMontagne on appele a la methode toxml pour g�nrer l'XML de l'�l�ment mountain 
              output := XMLType.appendchildxml(output,'province', tmpMontagne(indx).toXML());   
            end loop;
          for indx IN 1..tmpdesert.COUNT
            loop
             --pour chaque desert de tmpdesert on appele a la methode toxml pour g�nrer l'XML de l'�l�ment desert 
              output := XMLType.appendchildxml(output,'province', tmpdesert(indx).toXML());   
            end loop;
          for indx IN 1..tmpisland.COUNT
          --pour chaque island de tmpisland on appele a la methode toxml pour g�nrer l'XML de l'�l�ment island 
            loop
              output := XMLType.appendchildxml(output,'province', tmpisland(indx).toXML());   
            end loop;
        end if ; 
        end if ;
      return output;--output contient null ou la structure de l'xml de l'�l�ment province
   end;
end;
/
--on cr�e la table qui contient les objets de type T_provinc
create table Lesprovinces of T_provinc;
/
--pour repr�senter l'�l�ment country on cr�e le type T_Pays
create or replace  type T_Pays as object (
   NAME        VARCHAR2(35 Byte),--contient le nom du pays 
   CODE        VARCHAR2(4 Byte),--contient le code du pays
   CAPITAL     VARCHAR2(35 Byte),--contient la capital du pays
   PROVINCE    VARCHAR2(35 Byte),--contient la province du pays 
   AREA        NUMBER,--cntient l'area du pays
   POPULATION  NUMBER,--contient la population du pays 
   member function toXML return XMLType-- une m�thode pour g�nrer l'XML de l'�l�ment country
)
/
--on cr�e le type T_enscontinent pour stocker les objets de type T_continent pour 
--representer l'element continent+ qui existe dans l'�lement country
create or replace type T_enscontinent as table of T_continent;
/
--on cr�e le type T_ensprovinc pour stocker les objets de type T_provinc pour 
--representer l'element province+ qui existe dans l'�lement country
create or replace type T_ensprovinc as table of T_provinc;
/
--on cr�e le type T_ensairport pour stocker les objets de type T_airport pour 
--representer l'element airport* qui existe dans l'�lement country
create or replace type T_ensairport as table of T_airport;
/
--on cr�e la table qui contient les objets de type T_Pays
create table LesPays of T_Pays;
/
--on cr�e le type T_enspays pour stocker les objets de type T_pays pour 
--representer l'element country+ qui existe dans l'�lement mondial
create or replace type T_enspays as table of T_pays;
/
create or replace type body T_Pays as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment country a la fin
   -- V_montagnes T_ensXML;
   tmpcontinent T_enscontinent;--variable contient un tableau d'objets de type T_continent
   tmpprovinc T_ensprovinc;--variable contient un tableau d'objets de type T_provinc
   tmpairport T_ensairport;--variable contient un tableau d'objets de type T_airport
   begin
    if self.CODE is null --dans l'�l�ment country code est un attribut #REQUIRED 
       then 
        --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment country 
        output := null;
       ELSE 
         if self.name is null --dans l'�l�ment country name est un attribut #REQUIRED 
          then 
           --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment country 
          output := null;
          ELSE
          -- sinon,si les deux attributs existe alors on cr�e l'�l�ment country comme elle d�finie dans le dtd 
          output := XMLType.createxml('<country idcountry="'||CODE||'" nom="'||name||'"></country>');
          --on trouve les continents du pays,on stock le resultat dans tmpcontinent
          select value(m) bulk collect into tmpcontinent
            from Lescontinent m
      where m.country=self.CODE  ;  
      --on trouve les provinces du pays,on stock le resultat dans tmpprovinc
      select value(m) bulk collect into tmpprovinc
      from Lesprovinces m
      where self.CODE = m.Country ;
      --on trouve les airports du pays,on stock le resultat dans tmpairport
      select value(m) bulk collect into tmpairport
      from Lesairports m
      where self.Code = m.Country ;
      for indx IN 1..tmpcontinent.COUNT
      loop
      --avec cette boucle on va representer continent+ donc pour chaque continent de tmpcontinent on appele a la methode toxml pour g�nrer l'XML de l'�l�ment continent 
         output := XMLType.appendchildxml(output,'country', tmpcontinent(indx).toXML());   
      end loop; 
      for indx IN 1..tmpprovinc.COUNT
      loop
      --avec cette boucle on va cr�er province+ donc pour chaque provice de tmpprovinc on appele a la methode toxml pour g�nrer l'XML de l'�l�ment province 
         output := XMLType.appendchildxml(output,'country', tmpprovinc(indx).toXML());   
      end loop;
      for indx IN 1..tmpairport.COUNT
      loop
       --avec cette boucle on va cr�er airport* donc pour chaque airport de tmpairport on appele a la methode toxml pour g�nrer l'XML de l'�l�ment airport 
         output := XMLType.appendchildxml(output,'country', tmpairport(indx).toXML());   
      end loop;
      end if ; 
      end if;
     return output;--output contient null ou la structure de l'xml de l�l�ment country
   end;
end;
/
--j'ai choisi de representer mondial comme un tableau contient un seul objet
--pour repr�senter l'�l�ment mondial on cr�e le type T_mondial
create type T_mondial as object(
id Number,--variable pour 
member function toXML return XMLType-- une m�thode pour g�nrer l'XML de l'�l�ment mondial
)
/
create or replace type body T_mondial as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment mondial a la fin
   tmppays T_enspays ;--variable contient un tableau d'objets de type T_pays
   begin
    output := XMLType.createxml('<mondial></mondial>');--on cr�e l'�lement mondial
   --on trouve tout les pays,on stock le resultat dans tmppays
    select value(p) bulk collect into tmppays
      from LesPays p 
      where p.code='F' or p.code='R' or p.code='USA';--j'ai pris un example de trois pays (France,USA,Russia) pour tester la validiter
    for indx IN 1..tmppays.COUNT
      loop
     --avec cette boucle on va cr�er country+ donc pour chaque pays de tmppays on appele a la methode toxml pour g�nrer l'XML de l'�l�ment country 
         output := XMLType.appendchildxml(output,'mondial',tmppays(indx).toXML()); 
      end loop;
     return output;--output contient la structure de l'xml de l�l�ment mondial
   end;
 end ;
/
--on cr�e la table qui contient les objets de type T_mondial
create table Lesmond of T_mondial;
/
-- on remplie la table LesPays en utilisant la table COUNTRY de la base de donn�es mondial
insert into LesPays
  select T_Pays(c.name, c.code, c.capital, 
         c.province, c.area, c.population) 
         from COUNTRY c;
-- la table Lesmond contient un seul objet
insert into Lesmond values(T_mondial(1));
-- on remplie la table Lesprovinces en utilisant la table PROVINCE de la base de donn�es mondial                  
insert into Lesprovinces
  select T_provinc(c.name, c.country, c.population, 
         c.area, c.capital, c.capprov) 
         from PROVINCE c;
-- on remplie la table LesMontagnes en utilisant la table GEO_MOUNTAIN (pour trouver le pays 
--zt la province de la montagne)et MOUNTAIN de la base de donn�es mondial                       
insert into  LesMontagnes
  select T_Montagne(m.name, m.mountains, m.height, 
         m.type, g.country,g.PROVINCE) 
         from MOUNTAIN m, GEO_MOUNTAIN g
         where g.MOUNTAIN=m.NAME;
-- on remplie la table Lesdesert en utilisant la table GEO_DESERT (pour trouver le pays 
--et la province du desert)et DESERT de la base de donn�es mondial                       

insert into Lesdesert
  select T_desert(m.name, m.area,g.COUNTRY,g.PROVINCE) 
         from DESERT m,GEO_DESERT g
         where g.DESERT=m.NAME;
-- on remplie la table Lesdesert en utilisant la table ENCOMPASSES de la base de donn�es mondial        
insert into Lescontinent
  select T_continent(m.CONTINENT,m.COUNTRY,m.PERCENTAGE) 
         from ENCOMPASSES m;
-- on remplie la table LesIslands en utilisant la table GEO_ISLAND (pour trouver le pays 
--et la province de l'sland)et ISLAND de la base de donn�es mondial  
         
insert into LesIslands
  select T_island(m.name, m.islands,m.area,m.height,m.type,g.COUNTRY,GEOCOORD(m.COORDINATES.latitude,m.COORDINATES.longitude),g.PROVINCE) 
         from ISLAND m,GEO_ISLAND g
         where g.ISLAND=m.NAME;
  
-- on remplie la table Lesairports en utilisant la table AIRPORT de la base de donn�es mondial        

insert into Lesairports 
   select T_airport(a.NAME,a.CITY,a.COUNTRY)
     from AIRPORT a ; 

-- exporter le r?sultat dans un fichier 
WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\exo1_dtd1.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select p.toXML().getClobVal() 
from Lesmond p;




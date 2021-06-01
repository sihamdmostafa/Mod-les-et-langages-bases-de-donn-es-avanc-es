--pour repr�senter l'�l�ment border  on cr�e le type T_border
create or replace  type T_border   as object (
   COUNTRY1         VARCHAR2(4 Byte),
   COUNTRY2         VARCHAR2(4 Byte),
   LENGTH           Number,-- contient longueur du border
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment border
)
/

create or replace type body T_border as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�mment border a la fin
   begin 
      if self.LENGTH is null --dans le dtd on a l'attribut length est #REQUIRED
       then 
       -- donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment border  
        output := null;
       ELSE 
         if self.COUNTRY2 is null--dans le dtd on a l'attribut countrycode est #REQUIRED
          then 
       -- donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment border  
          output := null;
           ELSE
             -- sinon,si les deux attributs existe alors on cr�e l'�l�ment border comme elle d�finie dans le dtd 
             output := XMLType.createxml('<border countryCode="'||self.COUNTRY2||'" length ="'||self.LENGTH||'"></border>');
         end if ; 
      end if;
      return output;--output contient null ou la structure de l'xml de l�l�ment border
   end;
end;
/
--on cr�e la table lesborder qui contient les objets de type T_border
create table lesborder of T_border;
/
--on cr�e ce type pour connaitre la continent de chaque Pays avec le percentage
create type pays_conti as object(
 Country        VARCHAR2(4 Byte),
 CONTINENT  VARCHAR2(20 Byte),
 PERCENTAGE Number 
)
/
--on cr�e la table qui contient les objets de type pays_conti
create table lespays_conti of pays_conti;
/
--pour repr�senter l'�l�ment country on cr�e le type T_Pays
create or replace  type T_Pays as object (
   NAME        VARCHAR2(35 Byte),--contient le nom du pays 
   CODE        VARCHAR2(4 Byte),--contient le code du pays
   CAPITAL     VARCHAR2(35 Byte),--contient la capital du pays
   PROVINCE    VARCHAR2(35 Byte),--contient la province du pays 
   AREA        NUMBER,--cntient l'area du pays
   POPULATION  NUMBER,--contient la population du pays
   member function  Sum_front return Number,--une m�thode pour calculer La longueur totale du fronti�re 
   member function  Continent_principale return varchar,--une m�thode pour determiner la continent principale
   member function toXML_contCountries return XMLType,-- une m�thode qui gen�re l'�lement contCountries
   member function toXML return XMLType-- une m�thode pour g�nrer l'XML de l'�l�ment country
)
/
--on cr�e le type T_ensborder pour stocker les objets de type T_border pour 
--representer l'element border* qui existe dans l'�lement contCountries 
create or replace type T_ensborder as table of T_border;
/
create or replace type body T_Pays as
   member function Sum_front return Number is 
   leng Number;--variable contient La longueur totale du fronti�re 
   begin
   leng:=0;--on l'initialise a 0 
   --on fait la somme de chaque fronti�re associer a self.code
   select distinct sum(m.LENGTH) into leng
      from lesborder m
      where m.COUNTRY1=self.code or m.COUNTRY2=self.code; 
   if leng is null --si le pays n'a pas de fronti�re (leng est null) alors on le met a 0
   then 
     leng := 0;
   end if ; 
   return leng;
   end;
   member function  Continent_principale return varchar is 
   res VARCHAR2(20 Byte) ; --contient la continent principale du pays
   begin 
   --on trouve la contient qui a plus grand de pourcentage associer a pays et on stock le resultat dans res
   select p.CONTINENT into res
   from lespays_conti p 
   where p.country=self.code and p.PERCENTAGE = (select max(m1.PERCENTAGE) from lespays_conti m1 where m1.COUNTRY=self.code); 
   return res;
   end;
   member function toXML_contCountries return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment contCountries  a la fin
   tmpbrders T_ensborder;--variable contient un tableau d'objets de type T_border
   begin
      --on cr�er l'�lement contCountries
      output := XMLType.createxml('<contCountries/>');
      --on trouve les pays qui est en border avec la pays de code self.code et qui se trouve dans 
      --la meme continent principal (en utilisant la m�thode Continent_principale),on stock le resultat dans tmpbrders
      select value(m) bulk collect into tmpbrders
      from lesborder m,lespays_conti c
      where m.COUNTRY1=self.code and c.COUNTRY=m.COUNTRY2 and c.CONTINENT=self.Continent_principale;
      for indx IN 1..tmpbrders.COUNT
      --avec cette boucle on va cr�er border* donc pour chaque border de tmpbrders on appele a la methode toxml pour g�nrer l'XML de l'�l�ment border 
      loop
         output := XMLType.appendchildxml(output,'contCountries', tmpbrders(indx).toXML());   
      end loop;
       --on fait la meme choose que pr�c�dent mais avec m.country2=self.code
      select T_Border(m.country2,m.country1,m.LENGTH) bulk collect into tmpbrders
      from lesborder m,lespays_conti c
      where m.COUNTRY2=self.code and c.COUNTRY=m.COUNTRY1 and c.CONTINENT=self.Continent_principale ;
       
      for indx IN 1..tmpbrders.COUNT
      loop
         output := XMLType.appendchildxml(output,'contCountries', tmpbrders(indx).toXML());   
      end loop;
      return output; 
   end;
   member function toXML return XMLType is
   output XMLType;--contient la structure de l'xml de l'�l�ment country
   -- V_montagnes T_ensXML;
   begin
      IF self.name is null or self.Continent_principale is null --dans le dtd on a name et CONTINENT sont des attributs #REQUIRED
       then  
        --donc si l'un des deux n'existe pas alors on enl�ve carr�ment l'�l�ment country
         output := null;
      ELSE 
         --sinon on constuit l'�lement comme mentionn� dans le dtd 
          output := XMLType.createxml('<pays name="'||NAME||'"  CONTINENT="'||self.Continent_principale||'" blength="'||self.Sum_front||'"></pays>');
          output := XMLType.appendchildxml(output,'pays',toXML_contCountries);   
      end if ; 
      return output;
   end;
end;
/
create table LesPays of T_Pays;
/
--pour repr�senter l'�l�ment ex2 on cr�e le type ex2
create type ex2 as object(
id Number,
member function toXML return XMLType
)
/
--on cr�e le type T_enspays2 pour stocker les objets de type T_pays 
create or replace type T_enspays2 as table of T_pays;
/
create or replace type body ex2 as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment ex2 a la fin
   tmppays T_enspays2 ; --variable contient un tableau d'objets de type T_pays
   begin
      --on cr�e l'objet ex2
    output := XMLType.createxml('<ex2></ex2>');
   --on trouve tout les pays,on stock le resultat dans tmppays
    select value(p) bulk collect into tmppays
      from LesPays p;
    for indx IN 1..tmppays.COUNT
      loop
        --avec cette boucle on va cr�er country+ donc pour chaque pays de tmppays on appele a la methode toxml pour g�nrer l'XML de l'�l�ment country 
         output := XMLType.appendchildxml(output,'ex2',tmppays(indx).toXML()); 
      end loop;
     return output;
   end;
 end ;
/
--on cr�e la table ex22 qui contient les objets de type ex2
create table ex22 of ex2;
/
-- la table ex21 contient un seul objet        
insert into ex22 values(ex2(1));

-- on remplie la table LesPays en utilisant la table COUNTRY de la base de donn�es mondial
insert into LesPays
  select T_Pays(c.name, c.code, c.capital,c.province,c.area, c.population) 
         from COUNTRY c;

-- on remplie la table lesborder en utilisant la table BORDERS de la base de donn�es mondial

insert into lesborder
  select T_border(m.COUNTRY1, m.COUNTRY2,m.LENGTH) 
         from BORDERS m ;  

-- on remplie la table lespays_conti en utilisant la table ENCOMPASSES de la base de donn�es mondial

insert into lespays_conti
  select pays_conti(m.Country,m.CONTINENT,m.PERCENTAGE) 
         from ENCOMPASSES m;    


WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\exo2_partie2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select p.toXML().getClobVal() 
from ex22 p;

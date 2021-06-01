
--pour repr�senter l'�l�ment country  on cr�e le type pays_conti
create type pays_conti as object(
 Country        VARCHAR2(4 Byte),--contient le pays 
 CONTINENT  VARCHAR2(20 Byte),--contient la continent du pays
 Population Number,--contient la population du pays
 member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment country
)
/
create or replace type body pays_conti as
member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment country a la fin
   begin
       if self.country is null or self.population is null --dans le dtd on name et population sont des attributs #REQUIRED
       then 
         --donc si l'un des deux n'existe pas alors on enl�ve carr�ment l'�l�ment country   
         output := null ; 
       else 
       output := XMLType.createxml('<country name="'||Country||'" population="'||Population||'"></country>');
       end if ;  
      return output;
   end;
end ; 
/
--on cr�e la table lespays_conti qui contient les objets de type pays_conti
create table lespays_conti of pays_conti;
/
--pour repr�senter l'�l�ment continent  on cr�e le type T_continent
create or replace  type T_continent  as object (
   name          VARCHAR2(20 Byte),--contient le nom du continent
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment continent
)
/
--on cr�e le type T_enspays pour stocker les objets de type pays_conti pour 
--representer l'element country* qui existe dans l'�lement continent
create or replace type T_enspays as table of pays_conti;
/
create or replace type body T_continent as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment continent a la fin
   tmppays T_enspays;--variable contient un tableau d'objets de type pays_conti
   begin
      if self.name is null --dans le dtd,name est #REQUIRED dans l'�lement continent  
      then 
        -- donc si il n'existe pas alors on ajoute pas l'�lement continent 
        output := null ; 
      else
      output := XMLType.createxml('<continent name="'||name||'"></continent>');
      --on trouve tout les pays associer a cette continent
      select value(c) bulk collect into tmppays
       from lespays_conti c
       where c.CONTINENT = self.name;
       --pour chaque pays de tmppays on appele a la methode toxml pour g�nrer l'XML de l'�l�ment country 
       for indx IN 1..tmppays.COUNT
       loop
          output := XMLType.appendchildxml(output,'continent', tmppays(indx).toXML());   
       end loop;
      end if ; 
      return output;
   end;
end;
/
--on cr�e la table qui contient les objets de type T_continent
create table Lescontinent of T_continent ;
/
--pour repr�senter l'�l�ment mondial on cr�e le type T_mondial
create type T_mondial1 as object(
id Number,
member function toXML return XMLType
)
/
--on cr�e le type T_ensconti pour stocker les objets de type T_continent pour 
--representer l'element country+ qui existe dans l'�lement mondial
create or replace type T_ensconti as table of T_continent;
/
create or replace type body T_mondial1 as
   member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment mondial a la fin
   tmpconti T_ensconti ;--variable contient un tableau d'objets de type T_continent
   begin
    --on cr�e l'�l�ment mondial 
    output := XMLType.createxml('<mondial></mondial>');
    --on trouve tout les continents,on stock le resultat dans tmpconti
    select value(p) bulk collect into tmpconti
      from Lescontinent p ;
    for indx IN 1..tmpconti.COUNT
      loop
      --avec cette boucle on va cr�er continent+ donc pour chaque continent de tmpconti on appele a la methode toxml pour g�nrer l'XML de l'�l�ment continent 
         output := XMLType.appendchildxml(output,'mondial',tmpconti(indx).toXML()); 
      end loop;
     return output;
   end;
 end ;
/
--on cr�e la table qui contient les objets de type T_mondial
create table Lesmond1 of T_mondial1;
/
-- la table Lesmond contient un seul objet
insert into Lesmond1 values(T_mondial1(1));
/
-- on remplie la table Lescontinent en utilisant la table CONTINENT de la base de donn�es mondial

insert into Lescontinent
  select T_continent(m.NAME) 
         from CONTINENT m;
         
-- on remplie la table lespays_conti en utilisant la table ENCOMPASSES (pour trouver la continent) et COUNTRY (pour le
--nom et la population)de la base de donn�es mondial

insert into lespays_conti
  select pays_conti(m.COUNTRY,m.CONTINENT,c.POPULATION) 
         from ENCOMPASSES m,COUNTRY c
         where m.COUNTRY=c.code;
      

WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\req1.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/       
select p.toXML().getClobVal() 
from Lesmond1 p;

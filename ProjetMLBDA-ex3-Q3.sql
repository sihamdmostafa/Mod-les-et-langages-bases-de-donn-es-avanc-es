--GEOCOORD est un type qui contient la longitude et l'atitude d'un objet (island,desert,river..) dans 
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

create or replace  type T_Montagne as object (
   NAME         VARCHAR2(35 Byte),--contient le nom du montagne
   HEIGHT       NUMBER,--contient la hauteur du montagne
   Province         VARCHAR2(35),--contient la province du montagne
   cord          GEOCOORD,--contient les coordonn�s du montagne
   member function toXML return XMLType -- une m�thode pour g�nrer l'XML de l'�l�ment mountain
)
/

create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;--variable contient l'XML de l'�l�ment mountain a la fin
   begin
     if self.name is null or self.HEIGHT is null then --dans on le dtd on l'attribut name et HEIGHT de l�l�ment continent sont #REQUIRED
      --donc si l'un des deux attributs n'existe pas alors on enl�ve carr�ment l'�l�ment mountain 
      output := null ; 
     else 
      output := XMLType.createxml('<mountain name="'||name||'" altitude="'||HEIGHT||'"></mountain>');
      output := XMLType.appendchildxml(output,'mountain',cord.toXML());
     end if ;  
     return output;
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
create or replace type body T_provinc as
   member function toXML return XMLType is
   output XMLType;
   tmpMontagne T_ensMontagne;--variable contient un tableau d'objets de type T_Montagne 
   val Number;
   begin
      if self.name is null--dans  le dtd on a l'attribut name de l�l�ment province est #REQUIRED  
       then  
       --donc si il n'existe pas alors on enl�ve carr�ment l'�l�ment province 
        output := null ; 
      else 
      output := XMLType.createxml('<province name="'||name||'" country="'||Country||'"></province>');
      -- on trouve les montagnes de la province,on stock le resultat dans tmpMontagne 
      select value(m1) bulk collect into tmpMontagne
      from LesMontagnes m1
      where self.NAME = m1.Province;  
     for indx IN 1..tmpMontagne.COUNT
      loop
       --pour chaque montagne de tmpMontagne on appele a la methode toxml pour g�nrer l'XML de l'�l�ment mountain 
     output := XMLType.appendchildxml(output,'province', tmpMontagne(indx).toXML()); 
      end loop;
     end if ;   
     return output ; 
    end ;
    end;
/
create table Lesprovinc of T_provinc;
/
create or replace type T_ensprovinc as table of T_provinc;
/
create type T_mondial as object(
id Number,
member function toXML return XMLType
)
/
create or replace type body T_mondial as
   member function toXML return XMLType is
   output XMLType;
   tmpprovinc T_ensprovinc ; 
   begin
    output := XMLType.createxml('<mondial></mondial>');
    select value(p) bulk collect into tmpprovinc
      from Lesprovinc p ;
    for indx IN 1..tmpprovinc.COUNT
      loop
         output := XMLType.appendchildxml(output,'mondial',tmpprovinc(indx).toXML()); 
      end loop;
     return output;
   end;
 end ;
/
create table Lesmond of T_mondial;
/

insert into Lesmond values(T_mondial(1));

insert into  LesMontagnes
  select T_Montagne(m.NAME,m.HEIGHT,g.PROVINCE,GEOCOORD(m.COORDINATES.latitude,m.COORDINATES.longitude)) 
         from MOUNTAIN m, GEO_MOUNTAIN g
         where g.MOUNTAIN=m.NAME;
/

insert into Lesprovinc
  select T_provinc(c.name, c.country, c.population, 
         c.area, c.capital, c.capprov) 
         from PROVINCE c;

-- exporter le r?sultat dans un fichier 
WbExport -type=text
         -file='C:\Users\hp\Downloads\Master\req3.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/  
       
select m.toXML().getClobVal() 
from Lesmond m ;

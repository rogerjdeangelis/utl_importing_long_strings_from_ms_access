Importing long strings from ms access

githubs
https://github.com/rogerjdeangelis/utl_importing_long_strings_from_ms_access
https://github.com/rogerjdeangelis/utl_exporting_longtext_fields_to_ms_access

see
https://tinyurl.com/ycwoaugf
https://communities.sas.com/t5/SAS-Programming/Reading-access-database-with-infile-statement/m-p/495667

There may be max length of $1024. Too lazy to use the
MS access using mutiple mid functions.

  mid(txt,1,1024))    as txt1
  mid(txt,1025,2048)) as txt2

Also passthrough exceute statement may help


INPUT  (MS access table with 400 char string)
=============================================

 d:\mdb\longtext.accdb

  Table LONGTEXT in ms access

   NAME    TXT (400 char string)

   Alfred  AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
           AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
           AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
           AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre


EXAMPLE OUTPUT (SAS Dataset)
----------------------------


  WORK.LONGTEXT

   NAME    TXT (400 char string)

   Alfred  AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
           AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
           AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
           AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre


PROCESS
=======

 proc sql dquote=ansi;
  connect to access as mydb (Path="d:\mdb\longtext.accdb");
    create
       table longtext as
    select
       name
      ,length(strip(txt)) as len length=400
      ,substr(txt,400,1) as endByt
      ,txt
    from connection to mydb
      (
       Select
         name
        ,txt
       from
            [longtext]
      );
 disconnect from mydb;
 quit;


OUTPUT  (enhanced output)
=========================

  NAME     LEN    ENDBYT  TXT

 Alfred    400      e     AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
                          AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
                          AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre
                          AlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfreAlfre


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

  This worked wit a 9000 length string.

  You may want to create your input accdb manually.

  This wasy very difficult because I could not get around the
  255 limit and I was unable to create an accdb using SAS.


  * I don't believe SAS can create a Access database so I suggest you copy
    a database provided by SAS.

  * you can use your system copy command or;
  %bincop(
     in=C:\Progra~1\sashome\SASFoundation\9.4\access\sasmisc\demo.accdb
   ,out=d:/mdb/longtext.accdb
  );

  * for larger files use Bruno Mueller macro;
  %binaryFileCopy(
  infile=_bcin
  , outfile=_bcout
  , returnName=_bcrc
  , chunkSize=16392
  );

  libname mdb access "d:/mdb/longtext.accdb";

  proc sql; drop table mdb.longtext; quit; * just in case you have longtext;

  data mdb.longtext;
   set sashelp.class(keep=name obs=1);;
  run;quit;
  libname mdb clear;

  proc sql dquote=ansi;
    connect to access as mydb (Path="d:\mdb\longtext.accdb");
      execute(
        alter table [longtext]
        add column txt memo) by mydb;
    disconnect from mydb;
  Quit;

  data _null_;
   length cmd1 $16000;
   set sashelp.class(obs=1 keep=name txt);
   length txt $400;
   txt=repeat(substr(name,1,5),79);
   call symputx('txt',quote(strip(txt)));
   call symputx('name',quote(strip(name)));
   cmd1=resolve('
      proc sql dquote=ansi;
      connect to access as mydb (Path="d:\mdb\longtext.accdb");
      execute(
        update [longtext]
        set txt=&txt
        where name=&name
      ) by mydb;
      disconnect from mydb;
  Quit;
  ');
  call execute(cmd1);
  run;quit;

  data _null_;
   length cmd1 $16000;
   set sashelp.class(obs=1 keep=name);
   length txt $400;
   txt=repeat(substr(name,1,5),79);
   call symputx('txt',quote(strip(txt)));
   call symputx('name',quote(strip(name)));
   cmd1=resolve('
      proc sql dquote=ansi;
      connect to access as mydb (Path="d:\mdb\longtext.accdb");
      execute(
        update [longtext]
        set txt=&txt
        where name=&name
      ) by mydb;
      disconnect from mydb;
  Quit;
  ');
  call execute(cmd1);
  run;quit;


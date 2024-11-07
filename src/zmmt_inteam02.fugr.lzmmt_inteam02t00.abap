*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 11.04.2024 at 16:51:26
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMMT_INTEAM02...................................*
DATA:  BEGIN OF STATUS_ZMMT_INTEAM02                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMT_INTEAM02                 .
CONTROLS: TCTRL_ZMMT_INTEAM02
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZMMT_INTEAM02                 .
TABLES: ZMMT_INTEAM02                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

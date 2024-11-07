*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.04.2024 at 08:37:31
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMMT_INTEAM01...................................*
DATA:  BEGIN OF STATUS_ZMMT_INTEAM01                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMT_INTEAM01                 .
CONTROLS: TCTRL_ZMMT_INTEAM01
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZMMT_INTEAM01                 .
TABLES: ZMMT_INTEAM01                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

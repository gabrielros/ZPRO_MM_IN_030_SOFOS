*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZMMT_INTEAM01
*   generation date: 01.04.2024 at 08:37:31
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZMMT_INTEAM01      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

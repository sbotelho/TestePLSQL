CREATE OR REPLACE PACKAGE IMPORTA_ARQ IS

PROCEDURE IMPORTACAO (pasta_entrada VARCHAR2,
                      arq_entrada   VARCHAR2);

END;
/
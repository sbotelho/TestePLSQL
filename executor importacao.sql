DECLARE 
  PASTA_ENTRADA VARCHAR2(250);
  ARQ_ENTRADA VARCHAR2(250);

BEGIN 
    PASTA_ENTRADA := '/u03/shared/lobato/Relatorios/';
    ARQ_ENTRADA   := 'base_teste.txt';

    IMPORTA_ARQ.IMPORTACAO ( PASTA_ENTRADA, ARQ_ENTRADA );
    COMMIT; 
END;
/ 

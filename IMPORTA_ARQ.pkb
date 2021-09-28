CREATE OR REPLACE PACKAGE BODY IMPORTA_ARQ IS

-- https://glufke.net/oracle/viewtopic.php?t=2529
FUNCTION VALIDA_CPF
      (p_cpf     IN CHAR)
       RETURN    BOOLEAN
IS
     m_total     NUMBER   :=  0;
     m_digito    NUMBER   :=  0;
BEGIN
     FOR i IN 1..9 LOOP
         m_total := m_total + substr(p_cpf,i,1) * (11 - i);
     END LOOP;

     m_digito := 11 - mod(m_total,11);

     IF m_digito > 9 THEN
        m_digito := 0;
     END IF;

     IF m_digito != substr(p_cpf,10,1) THEN
        RETURN FALSE;
     END IF;

     m_digito := 0;
     m_total  := 0;

     FOR i IN 1..10 LOOP
         m_total := m_total + substr(p_cpf,i,1) * (12 - i);
     END LOOP;

     m_digito := 11 - mod(m_total,11);

     IF m_digito > 9 THEN
        m_digito := 0;
     END IF;

     IF m_digito != substr(p_cpf,11,1) THEN
        RETURN FALSE;
     END IF;

     RETURN TRUE;

end;

--https://glufke.net/oracle/viewtopic.php?t=2529
FUNCTION VALIDA_CNPJ
      (p_cgc     IN CHAR)
       RETURN    BOOLEAN
IS
     m_total     NUMBER   :=  0;
     m_digito    NUMBER   :=  0;
BEGIN
     FOR i IN 1..4 LOOP
         m_total := m_total + substr(p_cgc,i,1) * (6 - i);
     END LOOP;

     FOR i IN 5..12 LOOP
         m_total := m_total + substr(p_cgc,i,1) * (14 - i);
     END LOOP;

     m_digito := 11 - mod(m_total,11);

     IF m_digito > 9 THEN
        m_digito := 0;
     END IF;

     IF m_digito != substr(p_cgc,13,1) THEN
        RETURN FALSE;
     END IF;

     m_digito := 0;
     m_total  := 0;

     FOR i IN 1..5 LOOP
         m_total := m_total + substr(p_cgc,i,1) * (7 - i);
     END LOOP;

     FOR i IN 6..13 LOOP
         m_total := m_total + substr(p_cgc,i,1) * (15 - i);
     END LOOP;

     m_digito := 11 - mod(m_total,11);

     IF m_digito > 9 THEN
        m_digito := 0;
     END IF;

     IF m_digito != substr(p_cgc,14,1) THEN
        RETURN FALSE;
     END IF;

     RETURN TRUE;
end;

PROCEDURE IMPORTACAO (pasta_entrada VARCHAR2,
                      arq_entrada   VARCHAR2) IS

 LC_CONT            NUMBER(12) := 0; 

-- pasta_entrada  varchar2(250);
-- arq_entrada  varchar2(250); 
 arq                utl_file.file_type;
 linha              varchar2(300); 
 
 posicao            number(3)       ;
 eof                boolean := false; -- FLAG QUE INDICA FIM DO ARQUIVO.


 LCPF               NUMBER(14);        
 LPRIVATE           NUMBER(1);
 LINCOMPLETO        NUMBER(1);
 LDT_ULT_COMPRA     DATE; 
 LTICKET_MÉDIO      NUMBER(12,2); 
 LTICKET_ULT_COMPRA NUMBER(12,2);
 LLOJA_MAIS_FREQ    NUMBER(14);
 LLOJA_ULT_COMPRA   NUMBER(14);
 LCPF_VALIDO        CHAR(1);
 LCNJP_FREQ_VALIDO  CHAR(1);
 LCNJP_ULT_VALIDO   CHAR(1);

 
 
BEGIN 

--   pasta_entrada := '/u03/shared/lobato/Relatorios/';
--   arq_entrada := 'base_teste.txt';
   
   arq := utl_file.fopen(pasta_entrada,arq_entrada,'r') ;
   
   DBMS_OUTPUT.PUT_LINE ('INICIO ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')  );
  
    while not(eof) loop
      
      begin
         -- ARMAZENA A LINHA DO ARQUIVO NA VARIÁVEL 'linha'
         utl_file.get_line(arq,linha);
          
              LC_CONT := LC_CONT + 1;
              
              LCPF_VALIDO        := 'N';
              LCNJP_FREQ_VALIDO  := 'N';
              LCNJP_ULT_VALIDO   := 'N';
              
              
                 --DBMS_OUTPUT.PUT_LINE ('LC_CONT ' || LC_CONT);
              ---LC_CONT = 1 é o cabeçalho
               
              if LC_CONT > 1 then 
                
                  linha          := trim(linha);
                  --DBMS_OUTPUT.PUT_LINE (linha);
                                    
                  posicao        := instr(linha,' ');
                  LCPF           := TO_NUMBER(REPLACE(REPLACE(REPLACE(substr(linha,1,posicao - 1),'.',''),'-',''),'/',''));
                  linha          := ltrim(substr(linha,posicao + 1));
                  
                  posicao        := instr(linha,' ');
                  LPRIVATE       := TO_NUMBER(substr(linha,1,posicao - 1));
                  linha          := ltrim(substr(linha,posicao + 1));

                  posicao        := instr(linha,' ');
                  LINCOMPLETO    := TO_NUMBER(substr(linha,1,posicao - 1));
                  linha          := ltrim(substr(linha,posicao + 1));

                  posicao        := instr(linha,' ');
                  IF substr(linha,1,posicao - 1) = 'NULL' THEN 
                     LDT_ULT_COMPRA := NULL;
                  ELSE
                     LDT_ULT_COMPRA := TO_DATE(substr(linha,1,posicao - 1),'YYYY/MM/DD');
                  END IF;
                  linha          := ltrim(substr(linha,posicao + 1));

                  posicao        := instr(linha,' ');
                  IF substr(linha,1,posicao - 1) = 'NULL' THEN 
                     LTICKET_MÉDIO := NULL;
                  ELSE
                     LTICKET_MÉDIO  := substr(linha,1,posicao - 1);
                  END IF;
                  linha          := ltrim(substr(linha,posicao + 1));

                  posicao               := instr(linha,' ');
                  IF substr(linha,1,posicao - 1) = 'NULL' THEN 
                     LTICKET_ULT_COMPRA := NULL;
                  ELSE
                     LTICKET_ULT_COMPRA  := substr(linha,1,posicao - 1);                     
                  END IF;
                  
                  linha                 := ltrim(substr(linha,posicao + 1));

                  posicao           := instr(linha,' ');
                  IF substr(linha,1,posicao - 1) = 'NULL' THEN 
                     LLOJA_MAIS_FREQ := NULL;
                  ELSE
                     LLOJA_MAIS_FREQ   := TO_NUMBER(REPLACE(REPLACE(REPLACE(substr(linha,1,posicao - 1),'.',''),'-',''),'/',''));
                  END IF;                     
                  linha             := ltrim(substr(linha,posicao + 1));

                  linha := Translate(substr(linha,1), Chr (10)||Chr (13)||Chr (9)||Chr(11), ' ');
                  IF linha = 'NULL' THEN 
                     LLOJA_ULT_COMPRA := NULL;
                  ELSE                  
                     LLOJA_ULT_COMPRA  := TO_NUMBER(REPLACE(REPLACE(REPLACE(linha,'.',''),'-',''),'/',''));
                  END IF;
                  

                    -- VERIFICA SE O CPF OU CNPJ SÃO VÁLIDOS                  
                  IF VALIDA_CPF(LCPF) THEN 
                     LCPF_VALIDO := 'S';
                  END IF;

                  IF NVL(LLOJA_MAIS_FREQ,0) > 0 AND VALIDA_CNPJ(LLOJA_MAIS_FREQ) THEN 
                     LCNJP_FREQ_VALIDO := 'S';
                  END IF;

                  IF NVL(LLOJA_ULT_COMPRA,0) > 0  AND VALIDA_CNPJ(LLOJA_ULT_COMPRA) THEN 
                     LCNJP_ULT_VALIDO := 'S';
                  END IF;
                  
--                  DBMS_OUTPUT.PUT_LINE (LCPF || '.' || 
--                                            LPRIVATE || '.' ||
--                                            LINCOMPLETO || '.' ||
--                                            LDT_ULT_COMPRA || '.' || 
--                                            LTICKET_MÉDIO || '.' ||
--                                            LTICKET_ULT_COMPRA || '.' ||
--                                            LLOJA_MAIS_FREQ || '.' ||
--                                            LLOJA_ULT_COMPRA 
--                                            --|| '.' ||
----                                            LCPF_VALIDO
--                                           );

                -- INSERE NA TABELA DE HISTCOMPRAS                  
                  INSERT INTO HISTCOMPRAS 
                  (CPF, PRIVATEX, INCOMPLETO, DT_ULT_COMPRA, TICKET_MÉDIO, TICKET_ULT_COMPRA,
                   LOJA_MAIS_FREQ, LOJA_ULT_COMPRA, CPF_VALIDO, CNJP_FREQ_VALIDO, CNJP_ULT_VALIDO,
                   DT_ATUALIZACAO
                  )
                  VALUES 
                  (LCPF, LPRIVATE, LINCOMPLETO, LDT_ULT_COMPRA, LTICKET_MÉDIO, LTICKET_ULT_COMPRA,
                   LLOJA_MAIS_FREQ, LLOJA_ULT_COMPRA, LCPF_VALIDO, LCNJP_FREQ_VALIDO, LCNJP_ULT_VALIDO,
                   SYSDATE
                  );
                   
                  
             end if;
             
         IF LC_CONT MOD 500 = 0 THEN
            COMMIT;
         END IF;  
         
      Exception            
             when no_data_found then
                 eof := true;
      end;
                  
    end loop;
    
    UTL_FILE.fclose(arq);

  COMMIT;

   DBMS_OUTPUT.PUT_LINE ('FIM ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')  );

Exception
    when others then
      DBMS_OUTPUT.PUT_LINE (LC_CONT);     
END;

END IMPORTA_ARQ;
/
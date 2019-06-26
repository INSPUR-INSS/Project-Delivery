CREATE OR REPLACE PROCEDURE ACTUALIZA_PAGAMENTO_ANTECIPADO IS

 DT_INICO DATE;
 DT_FIM DATE;

 CURSOR LIST_BENE IS
       SELECT ID_BENEFICIARIO,
              TO_DATE(DT_INICO,'DD/MM/YYYY') DT_INICO,
              TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(DT_INICO,'DD/MM/YYYY'),12)-1,'DD/MM/YYYY'),'DD/MM/YYYY') DT_FIM 
       FROM ( SELECT T1.ID_BENEFICIARIO,MAX(TO_CHAR(T1.DATA_REFERENCIA,'DD/MM/YYYY')) DT_INICO 
                FROM IGSS.ARR_DECLARACAO_REMUNERACAO T1
               WHERE ID_BENEFICIARIO IN (SELECT ID_BENEFICIARIO FROM IGSS.REQ_PAGAMENTO_ANTECIPADO)
                 AND T1.ID NOT IN (
                           SELECT T2.ID_FOLHA_REMUNERACAO 
                             FROM IGSS.ARR_GUIA T2
                            WHERE T2.ID IN (
                                  SELECT T3.ID_GUIA
                                    FROM IGSS.REQ_ANTECIPADO_GUIA T3, IGSS.REQ_PAGAMENTO_ANTECIPADO T4
                                   WHERE T2.ID = T3.ID_GUIA
                                     AND T4.ID = T3.ID_REQ_PAGAMENTO_ANTICEPADO))
              GROUP BY T1.ID_BENEFICIARIO)
        UNION
         SELECT ID_BENEFICIARIO,
                TO_DATE(TRUNC(DATA_REGISTO,'MM'),'DD/MM/YYYY') DATA_INICO,
                TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(TRUNC(DATA_REGISTO,'MM'),'DD/MM/YYYY'),12)-1,'DD/MM/YYYY'),'DD/MM/YYYY') DT_FIM
         FROM IGSS.REQ_PAGAMENTO_ANTECIPADO 
        WHERE ID_BENEFICIARIO NOT IN (SELECT T1.ID_BENEFICIARIO FROM ARR_DECLARACAO_REMUNERACAO T1
              WHERE ID_BENEFICIARIO IN (SELECT ID_BENEFICIARIO FROM REQ_PAGAMENTO_ANTECIPADO)
                AND T1.ID NOT IN (
                          SELECT T2.ID_FOLHA_REMUNERACAO 
                            FROM ARR_GUIA T2
                           WHERE T2.ID IN (
                                 SELECT T3.ID_GUIA
                                   FROM REQ_ANTECIPADO_GUIA T3, REQ_PAGAMENTO_ANTECIPADO T4
                                  WHERE T2.ID = T3.ID_GUIA
                                    AND T4.ID = T3.ID_REQ_PAGAMENTO_ANTICEPADO))
              GROUP BY T1.ID_BENEFICIARIO);
  
BEGIN
  FOR C IN LIST_BENE LOOP
    
    DT_INICO :=  C.DT_INICO;
    DT_FIM := C.DT_FIM; 

    --ACTUALIZAR
    UPDATE REQ_PAGAMENTO_ANTECIPADO T SET T.DT_INICIO_DECLARACAO = C.DT_INICO WHERE T.ID_BENEFICIARIO = C.ID_BENEFICIARIO AND T.DT_INICIO_DECLARACAO IS NULL;
 
    UPDATE REQ_PAGAMENTO_ANTECIPADO T SET T.DT_FIM_DECLARACAO = C.DT_FIM WHERE T.ID_BENEFICIARIO = C.ID_BENEFICIARIO AND T.DT_FIM_DECLARACAO IS NULL;
 
    COMMIT;
 
 END LOOP;

END ACTUALIZA_PAGAMENTO_ANTECIPADO; 
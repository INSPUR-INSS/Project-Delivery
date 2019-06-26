
with C as (SELECT TO_DATE('01/' || TO_CHAR((CASE WHEN NVL(DATA_INICI_ACTIV, DATA_INSCR) < DATA_AMBIT THEN DATA_AMBIT ELSE NVL(DATA_INICI_ACTIV, DATA_INSCR) END), 'MM/YYYY'), 'DD/MM/YYYY') as DATA_INI,
       TO_DATE('01/' || TO_CHAR(SYSDATE, 'MM/YYYY'), 'DD/MM/YYYY') as DATA_FIM ,DATA_INSCR, DATA_INICI_ACTIV,DATA_AMBIT, ID FROM ID_CONTR where numer_contr = '9004565')

--SELECT COUNT(*) FROM (
SELECT (select id from C) AS ID_CONTR, MONTHS.REFERENCIA,
             (CASE
               WHEN NOT FR.DATA_REFER IS NULL THEN  'S'
               WHEN VER_CONTR_ATIVO_NA_REF((select id from C), MONTHS.REFERENCIA) = 'N' THEN
                CASE
                  WHEN (select count(*) from id_situa_contr isc where isc.contr_id in (select id from C) and isc.data_inici < MONTHS.REFERENCIA) > 0 THEN 'I' ELSE 'N' END ELSE 'N' END) AS DATA_SOP,
             (CASE
               WHEN NOT DR.DATA_REFERENCIA IS NULL THEN 'S'
               WHEN VER_CONTR_ATIVO_NA_REF(((select id from C)), MONTHS.REFERENCIA) = 'N' THEN
                CASE  WHEN (select count(*) from id_situa_contr isc where isc.contr_id in (select id from C) and isc.data_inici < MONTHS.REFERENCIA) > 0 THEN 'I' ELSE 'N' END ELSE 'N' END) AS DATA_SSISMO
        FROM (SELECT ADD_MONTHS((select DATA_INI from C), ROWNUM - 1) REFERENCIA
                FROM DUAL
               WHERE MONTHS_BETWEEN((select DATA_FIM from C), (select DATA_INI from C)) >= 0
              CONNECT BY LEVEL <= ROUND(MONTHS_BETWEEN((select DATA_FIM from C), (select DATA_INI from C)))) MONTHS
        LEFT JOIN (SELECT DATA_REFER, CONTR_ID, COUNT(*) FROM RE_FOLHA_REMUN WHERE ESTADO IN ('VA', 'CE')
                    GROUP BY DATA_REFER, CONTR_ID) FR
          ON FR.CONTR_ID in (select id from C)
         AND FR.DATA_REFER = MONTHS.REFERENCIA
        LEFT JOIN (SELECT DATA_REFERENCIA, ID_CONTRIBUINTE, COUNT(*) FROM ARR_DECLARACAO_REMUNERACAO WHERE IND_TEMP = 'N'
                    GROUP BY DATA_REFERENCIA, ID_CONTRIBUINTE) DR
          ON DR.ID_CONTRIBUINTE in (select id from C)
         AND DR.DATA_REFERENCIA = MONTHS.REFERENCIA
--) D WHERE (CASE WHEN D.DATA_SOP = 'S' OR D.DATA_SSISMO = 'S' THEN 'S' ELSE 'N'END) = 'N';





select * from ARR_MAPA_ENTREGA where id_contribuinte in (select id from id_contr where numer_contr = 9071025);



SELECT TO_DATE('01/' || TO_CHAR(
            (CASE WHEN NVL(DATA_INICI_ACTIV, DATA_INSCR) < DATA_AMBIT
                       THEN DATA_AMBIT
                  ELSE NVL(DATA_INICI_ACTIV, DATA_INSCR)
              END), 'MM/YYYY'), 'DD/MM/YYYY') as DATA_INI FROM igss.ID_CONTR where ID = 2089041;

select CASE WHEN TO_CHAR(SYSDATE, 'DD') < 20
                           THEN TO_DATE('01/' || TO_CHAR(SYSDATE, 'MM/YYYY'), 'DD/MM/YYYY')
                      ELSE TO_DATE('01/' || TO_CHAR(ADD_MONTHS(SYSDATE, 1), 'MM/YYYY'), 'DD/MM/YYYY')
                           END from dual;


with C as (SELECT TO_DATE('01/' || TO_CHAR((CASE WHEN NVL(DATA_INICI_ACTIV, DATA_INSCR) < DATA_AMBIT THEN DATA_AMBIT ELSE NVL(DATA_INICI_ACTIV, DATA_INSCR) END), 'MM/YYYY'), 'DD/MM/YYYY') as DATA_INI,
       TO_DATE('01/' || TO_CHAR(SYSDATE, 'MM/YYYY'), 'DD/MM/YYYY') as DATA_FIM ,DATA_INSCR, DATA_INICI_ACTIV,DATA_AMBIT, ID FROM ID_CONTR where numer_contr = '9071025')

--SELECT COUNT(*) FROM (
SELECT (select id from C) AS ID_CONTR, MONTHS.REFERENCIA,
             (CASE
               WHEN NOT FR.DATA_REFER IS NULL THEN  'S'
               WHEN VER_CONTR_ATIVO_NA_REF((select id from C), MONTHS.REFERENCIA) = 'N' THEN
                CASE
                  WHEN (select count(*) from id_situa_contr isc where isc.contr_id in (select id from C) and isc.data_inici < MONTHS.REFERENCIA) > 0 THEN 'I' ELSE 'N' END ELSE 'N' END) AS DATA_SOP,
             (CASE
               WHEN NOT DR.DATA_REFERENCIA IS NULL THEN 'S'
               WHEN VER_CONTR_ATIVO_NA_REF(((select id from C)), MONTHS.REFERENCIA) = 'N' THEN
                CASE  WHEN (select count(*) from id_situa_contr isc where isc.contr_id in (select id from C) and isc.data_inici < MONTHS.REFERENCIA) > 0 THEN 'I' ELSE 'N' END ELSE 'N' END) AS DATA_SSISMO
        FROM (SELECT ADD_MONTHS((select DATA_INI from C), ROWNUM - 1) REFERENCIA
                FROM DUAL
               WHERE MONTHS_BETWEEN((select DATA_FIM from C), (select DATA_INI from C)) >= 0
              CONNECT BY LEVEL <= ROUND(MONTHS_BETWEEN((select DATA_FIM from C), (select DATA_INI from C)))) MONTHS
        LEFT JOIN (SELECT DATA_REFER, CONTR_ID, COUNT(*) FROM RE_FOLHA_REMUN WHERE ESTADO IN ('VA', 'CE')
                    GROUP BY DATA_REFER, CONTR_ID) FR
          ON FR.CONTR_ID in (select id from C)
         AND FR.DATA_REFER = MONTHS.REFERENCIA
        LEFT JOIN (SELECT DATA_REFERENCIA, ID_CONTRIBUINTE, COUNT(*) FROM ARR_DECLARACAO_REMUNERACAO WHERE IND_TEMP = 'N'
                    GROUP BY DATA_REFERENCIA, ID_CONTRIBUINTE) DR
          ON DR.ID_CONTRIBUINTE in (select id from C)
         AND DR.DATA_REFERENCIA = MONTHS.REFERENCIA
--) D WHERE (CASE WHEN D.DATA_SOP = 'S' OR D.DATA_SSISMO = 'S' THEN 'S' ELSE 'N'END) = 'N';

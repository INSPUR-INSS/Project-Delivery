select c.id, c.NUMER_CONTR || c.NUMER_ESTAB numero, c.NOME_COMER "NOME COMERCIAL", c.NOME_INDIV "NOME INDIVIDUAL", c.MORAD_SEDE || '; ' || c.MORAD_ESTAB "ENDERECO", c.TELEF_SEDE "CONACTO", p.NOME PROVINCIA,
       igss.calcula_total_trabalhadores(c.id) trabalhadores,igss.ver_guias_pagas(c.id),VER_NUM_MESES_E_DECL(c.id)
from igss.id_contr c, igss.pa_provi p 
where c.id = igss.ver_guias_pagas(c.id)-- condicao para avaliar guias nao pagas
-- and igss.VER_NUM_MESES_E_DECL(c.id) = 'S'
and p.ID = c.provi_id1
and c.ID =1581981 concat(numer_contr,numer_estab) in ('110985400');

select a.*,rowid from arr_declaracao_remuneracao A where id_contribuinte in (select id from id_contr where numer_contr = '9044355');
select a.*,rowid from ARR_MAPA_ENTREGA a where id_contribuinte in (select id from id_contr where numer_contr LIKE '%9004565%');
SELECT * FROM ARR_MAPA_ENTREGA_TEMP  a where id_contribuinte in (select id from id_contr where numer_contr = '1109866');

insert into arr_declaracao_remuneracao (ID, ID_CONTRIBUINTE, ID_BENEFICIARIO, DATA_REFERENCIA, DATA_MOVIMENTO, DATA_RECEPCAO, QUANTIDADE_BENEFICIARIOS, TOTAL_REMUNERACAO, TOTAL_BONUS, TOTAL_SUBISIDIO, TOTAL_REMUNERACAO_CALCULADA, TOTAL_CONTRIBUICAO_A_PAGAR, TOTAL_CONTRIBUICAO_CONTRIB, VALOR_PERC_CONTRIBUINTE, TOTAL_CONTRIBUICAO_BENEF, VALOR_PERC_BENEFICIARIO, TOTAL_MULTA_ATRASO_ENTREGA, ID_REQUERIMENTO, FOLRE_ID, NUMERO, COD_USUARIO_ATU, DT_ATU, IND_TEMP, ID_BENEF_ORI, IND_VALID)
values (arr_declaracao_remuneracao_sq.nextval, 1581981, null, to_date('01-03-2019', 'dd-mm-yyyy'), to_date('01-03-2019 17:05:53', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-03-2019 17:06:00', 'dd-mm-yyyy hh24:mi:ss'), 4, 33750.00, 0.00, 0.00, 33750.00, 2362.50, 1350.00, 4.000, 1012.50, 3.00, 0.00, null, null, 0, 'C904435500', to_date('01-03-2019 17:06:00', 'dd-mm-yyyy hh24:mi:ss'), 'N', null, '1');

insert into arr_declaracao_remuneracao (ID, ID_CONTRIBUINTE, ID_BENEFICIARIO, DATA_REFERENCIA, DATA_MOVIMENTO, DATA_RECEPCAO, QUANTIDADE_BENEFICIARIOS, TOTAL_REMUNERACAO, TOTAL_BONUS, TOTAL_SUBISIDIO, TOTAL_REMUNERACAO_CALCULADA, TOTAL_CONTRIBUICAO_A_PAGAR, TOTAL_CONTRIBUICAO_CONTRIB, VALOR_PERC_CONTRIBUINTE, TOTAL_CONTRIBUICAO_BENEF, VALOR_PERC_BENEFICIARIO, TOTAL_MULTA_ATRASO_ENTREGA, ID_REQUERIMENTO, FOLRE_ID, NUMERO, COD_USUARIO_ATU, DT_ATU, IND_TEMP, ID_BENEF_ORI, IND_VALID)
values (arr_declaracao_remuneracao_sq.nextval, 1581981, null, to_date('01-04-2019', 'dd-mm-yyyy'), to_date('01-03-2019 17:05:53', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-03-2019 17:06:00', 'dd-mm-yyyy hh24:mi:ss'), 4, 33750.00, 0.00, 0.00, 33750.00, 2362.50, 1350.00, 4.000, 1012.50, 3.00, 0.00, null, null, 0, 'C904435500', to_date('01-03-2019 17:06:00', 'dd-mm-yyyy hh24:mi:ss'), 'N', null, '1');

insert into arr_declaracao_remuneracao (ID, ID_CONTRIBUINTE, ID_BENEFICIARIO, DATA_REFERENCIA, DATA_MOVIMENTO, DATA_RECEPCAO, QUANTIDADE_BENEFICIARIOS, TOTAL_REMUNERACAO, TOTAL_BONUS, TOTAL_SUBISIDIO, TOTAL_REMUNERACAO_CALCULADA, TOTAL_CONTRIBUICAO_A_PAGAR, TOTAL_CONTRIBUICAO_CONTRIB, VALOR_PERC_CONTRIBUINTE, TOTAL_CONTRIBUICAO_BENEF, VALOR_PERC_BENEFICIARIO, TOTAL_MULTA_ATRASO_ENTREGA, ID_REQUERIMENTO, FOLRE_ID, NUMERO, COD_USUARIO_ATU, DT_ATU, IND_TEMP, ID_BENEF_ORI, IND_VALID)
values (arr_declaracao_remuneracao_sq.nextval, 1581981, null, to_date('01-05-2019', 'dd-mm-yyyy'), to_date('01-03-2019 17:05:53', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-03-2019 17:06:00', 'dd-mm-yyyy hh24:mi:ss'), 4, 33750.00, 0.00, 0.00, 33750.00, 2362.50, 1350.00, 4.000, 1012.50, 3.00, 0.00, null, null, 0, 'C904435500', to_date('01-03-2019 17:06:00', 'dd-mm-yyyy hh24:mi:ss'), 'N', null, '1');


select * from ARR_MAPA_ENTREGA where 

 select count(*)
  from (select  p.id, p.nome, i.data_inici, NVL(i.data_final, sysdate)as data_final
       from id_situa_contr i inner join PA_TIPO_SITCO p
       on i.tisic_id = p.id
    where  p.id in(1,21)) p 
  where ( data_inici between TO_DATE('01/' || TO_CHAR(REFERENCIA, 'MM/YYYY'), 'DD/MM/YYYY') and ADD_MONTHS(TO_DATE('01/' || TO_CHAR(REFERENCIA, 'MM/YYYY'), 'DD/MM/YYYY'), 1) -1
       OR data_final between TO_DATE('01/' || TO_CHAR(REFERENCIA, 'MM/YYYY'), 'DD/MM/YYYY') and ADD_MONTHS(TO_DATE('01/' || TO_CHAR(REFERENCIA, 'MM/YYYY'), 'DD/MM/YYYY'), 1) -1
       OR ( data_inici < TO_DATE('01/' || TO_CHAR(REFERENCIA, 'MM/YYYY'), 'DD/MM/YYYY') and ADD_MONTHS(TO_DATE('01/' || TO_CHAR(REFERENCIA, 'MM/YYYY'), 'DD/MM/YYYY'), 1) -1 < data_final ) );
    
    
select * from PA_TIPO_SITCO;
select * from id_situa_contr;

select round(months_between(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_FIM,'MM')),0)  from igss.id_contr

select * from id_contr where numer_contr|| numer_estab = '100589500';



select trunc(DATA_INICI_ACTIV,'MM'),trunc(DATA_INSCR,'MM'),nvl(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_INSCR,'MM')) from igss.id_contr t where id = '&ID';

select trunc(DATA_INSCR,'MM') from igss.id_contr where id =  '&ID';

select trunc(case when to_char(sysdate, 'DD') < 20 then trunc(sysdate-30)else trunc(sysdate)end, 'MM') from dual;

select round(months_between(trunc(case when to_char(sysdate, 'DD') < 20 then trunc(sysdate-30)else trunc(sysdate)end, 'MM'), (select nvl(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_INSCR,'MM')) 
from igss.id_contr t where id =  '&ID')), 0) from dual;

select trunc((select nvl(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_INSCR,'MM')) from igss.id_contr t where id =  '&ID') + 30,'MM') from dual;
         
select * from (
            select * from igss.arr_declaracao_remuneracao ss
            where IND_TEMP = 'N'and id_contribuinte = '&ID' and data_referencia >= to_date('20140401','yyyymmdd') and data_referencia <= to_date('20140601','yyyymmdd')
            union
            select data_refer , CONTR_ID 
            from igss.RE_FOLHA_REMUN f
            where f.ESTADO IN ('VA', 'CE') and CONTR_ID = '&ID' and data_refer >= to_date('20140401','yyyymmdd') and data_refer <= to_date('20140601','yyyymmdd')
          )
          where id_ct = '&ID'
          and dt_rf = (select nvl(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_INSCR,'MM')) from igss.id_contr t where id = '&ID');
 



select trunc(trunc(sysdate-30), 'MM') from dual;




 
 select * from (
          select data_referencia dt_rf, id_contribuinte id_ct from igss.arr_declaracao_remuneracao ss
          where IND_TEMP = 'N'
          union
          select data_refer , CONTR_ID 
          from igss.RE_FOLHA_REMUN f
          where f.ESTADO IN ('VA', 'CE')
          )
          where id_ct = 1145741
          and dt_rf >= (select nvl(trunc(DATA_INICI_ACTIV, 'MM'), trunc(DATA_INSCR, 'MM')) from igss.id_contr where id = 1145741);
          
 select distinct data_ref  from (
          select data_referencia as data_ref, id_contribuinte as id_ct from igss.arr_declaracao_remuneracao ss
          where IGSS.VER_CONTR_ATIVO_NA_REF(ID_CONTRIBUINTE, DATA_REFERENCIA) = 'S'
          and IND_TEMP = 'N'and id_contribuinte = 1145741
          union
          select data_refer , CONTR_ID 
          from igss.RE_FOLHA_REMUN f
          where f.ESTADO IN ('VA', 'CE')
          and IGSS.VER_CONTR_ATIVO_NA_REF(f.CONTR_ID, f.DATA_REFER) = 'S' and contr_id = 1145741
          )
          where id_ct = 1145741;
          
          
    with p as (
       select  p.id, p.nome, i.data_inici, NVL(i.data_final, sysdate)as data_final
       from id_situa_contr i inner join PA_TIPO_SITCO p
       on i.tisic_id = p.id
    where i.contr_id = 1145741 and p.id in(1,21))
  select count(*) 
  from p
  where ( data_inici between PRIM_DIA and ULT_DIA
       OR data_final between PRIM_DIA and ULT_DIA
       OR ( data_inici < PRIM_DIA and ULT_DIA < data_final ) );          
       
       
select round(months_between((trunc(case when to_char(sysdate, 'DD') < 20 then -- define a data final para o contador
                                      trunc(sysdate-30)
                                 else  
                                      trunc(sysdate)
                                 end, 'MM')), (select nvl(trunc(DATA_INICI_ACTIV, 'MM'), trunc(DATA_INSCR, 'MM')) from igss.id_contr where id =237921)), 0) from dual;
                                 
select trunc(case when to_char(sysdate, 'DD') < 20 then -- define a data final para o contador
                                      trunc(sysdate-30)
                                 else  
                                      trunc(sysdate)
                                 end,'MM') from dual;                                 


    select * from (
          select data_referencia as data_ref, id_contribuinte as id_ct from igss.arr_declaracao_remuneracao ss
          where IGSS.VER_CONTR_ATIVO_NA_REF(ID_CONTRIBUINTE, DATA_REFERENCIA) = 'S'
          and IND_TEMP = 'N'
          union
          select data_refer , CONTR_ID 
          from igss.RE_FOLHA_REMUN f
          where f.ESTADO IN ('VA', 'CE')
          and IGSS.VER_CONTR_ATIVO_NA_REF(f.CONTR_ID, f.DATA_REFER) = 'S'
          )
          where id_ct = 237921
          --and data_ref > data_ini_act --novo
          and data_ref <= trunc(case when to_char(sysdate, 'DD') < 20 then trunc(sysdate-30) else trunc(sysdate) end,'MM');
          
select * from ben_pensionista where

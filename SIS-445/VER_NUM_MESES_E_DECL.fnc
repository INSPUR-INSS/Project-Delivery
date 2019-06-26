CREATE OR REPLACE FUNCTION IGSS.VER_NUM_MESES_E_DECL(ID_CONTR IN NUMBER) RETURN VARCHAR IS
/*BY: EJ , Last Update: 17-04-2018*/
num_meses number;
total_decl number;
data_ini_act date;
data_insc date;
data_fim date;
ref_act date;

BEGIN
  
    total_decl := 0;    

    select nvl(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_INSCR,'MM')) into data_ini_act from igss.id_contr where id = ID_CONTR; -- pega data de inicio de actividade
    
    select trunc(DATA_INSCR,'MM') into data_insc from igss.id_contr where id = ID_CONTR; -- pega data de inscricao
    
    data_fim := case when to_char(sysdate, 'DD') < 20 then -- define a data final para o contador
                                      trunc(sysdate-30)
                                 else  
                                      trunc(sysdate)
                                 end;
                                 
    num_meses := igss.conta_meses_contr_ativo(id_contr);
    
    ref_act := data_ini_act;
    
    DBMS_OUTPUT.PUT_LINE('Data insc.:' || data_insc || '; Ref.:' || ref_act);
    
    DBMS_OUTPUT.PUT_LINE('Diferenca: ' || round(months_between(data_insc, data_ini_act),0));
    
    if round(months_between(data_insc, data_ini_act),0) > 1 then -- BEFORE: condicao era "> 0", mas por erros do processo manual de inscricao de contribuintes, nao se conta como devedor de declaracao se nao entregar a declaracao no 1o mes (referente ao inicio de actividade)
    
        DBMS_OUTPUT.PUT_LINE('Dentro do if!');
        
                         
        for i in 1..months_between(data_insc, data_ini_act) loop
        
          DBMS_OUTPUT.PUT_LINE('Dentro do FOR!');
          
          select total_decl + 1 into total_decl from (
            select data_referencia dt_rf, id_contribuinte id_ct from igss.arr_declaracao_remuneracao ss
            where IND_TEMP = 'N'
            union
            select data_refer , CONTR_ID 
            from igss.RE_FOLHA_REMUN f
            where f.ESTADO IN ('VA', 'CE')
          )
          where id_ct = ID_CONTR
          and dt_rf = ref_act;
          
         DBMS_OUTPUT.PUT_LINE('Cont.:' || total_decl || '; Mes:' || ref_act);
          
          ref_act := trunc(ref_act + 30,'MM');
              
        end loop;
        
    end if;
    
    select total_decl + count(distinct data_ref) into total_decl from (
          select data_referencia as data_ref, id_contribuinte as id_ct from igss.arr_declaracao_remuneracao ss
          where IGSS.VER_CONTR_ATIVO_NA_REF(ID_CONTRIBUINTE, DATA_REFERENCIA) = 'S'
          and IND_TEMP = 'N'
          union
          select data_refer , CONTR_ID 
          from igss.RE_FOLHA_REMUN f
          where f.ESTADO IN ('VA', 'CE')
          and IGSS.VER_CONTR_ATIVO_NA_REF(f.CONTR_ID, f.DATA_REFER) = 'S'
          )
          where id_ct = ID_CONTR
          --and data_ref > data_ini_act --novo
          and data_ref < trunc(data_fim,'MM');
   
    DBMS_OUTPUT.PUT_LINE('NUM: '||num_meses||'; DECL: '||total_decl);
          
  if total_decl = num_meses then
      RETURN 'S';
   end if;
   
   RETURN 'N';
    
 
END;
/
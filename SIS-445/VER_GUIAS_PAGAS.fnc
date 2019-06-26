CREATE OR REPLACE function IGSS.ver_guias_pagas(id_contr number) RETURN NUMBER IS 
/*By EJ, Last Update: 17-04-2018*/
ct_id number;
diff number;
data_fim date;

begin

diff := -1;

data_fim :=  case when to_char(trunc(sysdate,'DD'), 'DD') < 20 then
                trunc(sysdate-30,'MM')
                else 
                    trunc(sysdate,'MM')
             end;
DBMS_OUTPUT.PUT_LINE('Verificacao de guias');
select round(months_between(trunc(DATA_INICI_ACTIV,'MM'), trunc(DATA_FIM,'MM')),0) into diff 
         from igss.id_contr where id = id_contr;

select distinct g.ID_CONTRIBUINTE into ct_id
 from igss.arr_guia g
 where (g.DT_PAGAMENTO is not null
 and  trunc(g.REFERENCIA) < data_fim)
 and g.id_contribuinte = id_contr;

DBMS_OUTPUT.PUT_LINE('CONTR_ID: '|| ct_id);

return ct_id;

exception
    when no_data_found then
         
    DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND, DIFF: '|| diff);
    if diff between 0 and 1 then
         return id_contr;
    else
        return 0;
    end if;
    
end;
/
select c.NUMER_CONTR || c.NUMER_ESTAB numero,
       c.NOME_COMER "NOME COMERCIAL",
       c.NOME_INDIV "NOME INDIVIDUAL",
       c.MORAD_SEDE || '; ' || c.MORAD_ESTAB "ENDERECO",
       c.TELEF_SEDE "CONACTO",
       p.NOME PROVINCIA,
       igss.calcula_total_trabalhadores(c.id) trabalhadores
from igss.id_contr c, igss.pa_provi p 
where c.id = igss.ver_guias_pagas(c.id)-- condicao para avaliar guias nao pagas
and igss.VER_NUM_MESES_E_DECL(c.id) = 'S'
and p.ID = c.provi_id1;



select c.NUMER_CONTR || c.NUMER_ESTAB numero,
       c.NOME_COMER "NOME COMERCIAL",
       c.NOME_INDIV "NOME INDIVIDUAL",
       c.MORAD_SEDE || '; ' || c.MORAD_ESTAB "ENDERECO",
       c.TELEF_SEDE "CONACTO",
       p.NOME PROVINCIA,
       igss.calcula_total_trabalhadores(c.id) trabalhadores
from igss.id_contr c, igss.pa_provi p 
where c.id = igss.VER_GUIAS_PAGAS_NOVO(c.id)-- condicao para avaliar guias nao pagas
and igss.VER_NUM_MESES_E_DECL_NOVO(c.id) = 'S' -- New Function
and p.ID = c.provi_id1;

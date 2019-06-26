begin
  sys.dbms_scheduler.create_job(job_name            => 'IGSS.JOB_SENDEMAIL_DAILY',
                                job_type            => 'STORED_PROCEDURE',
                                job_action          => 'IGSS.PROC_SEND_EMAIL',
                                number_of_arguments => 10,
                                start_date          => to_date('21-06-2019 02:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=Daily;Interval=1',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => false,
                                auto_drop           => false,
                                comments            => '');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 1,
                                            argument_value    => 'Saudações Caros,
    Em anexo encontra-se a lista de contribuintes quites, extraída a {0}.
    Melhores cumprimentos.');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 2,
                                            argument_value    => 'Contribuintes Quites');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 3,
                                            argument_value    => 'imail@inss.gov.mz');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 4,
                                            argument_value    => 'simigra@inss.gov.mz');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 5,
                                            argument_value    => 'mail.inss.gov.mz');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 6,
                                            argument_value    => '25');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 7,
                                            argument_value    => 'Inss2019');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 8,
                                            argument_value    => 'MAIL_DIR');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 9,
                                            argument_value    => ' select c.NUMER_CONTR || c.NUMER_ESTAB numero,c.NOME_COMER "NOME COMERCIAL",c.NOME_INDIV "NOME INDIVIDUAL",c.MORAD_SEDE || ''; '' || c.MORAD_ESTAB "ENDERECO",c.TELEF_SEDE "CONACTO",p.NOME PROVINCIA,igss.calcula_total_trabalhadores(c.id) trabalhadores from igss.id_contr c, igss.pa_provi p where c.id = igss.ver_guias_pagas_novo(c.id) and igss.ver_num_meses_e_decl_novo(c.id) = ''S'' and p.ID = c.provi_id1 ');
  sys.dbms_scheduler.set_job_argument_value(job_name          => 'IGSS.JOB_SENDEMAIL_DAILY',
                                            argument_position => 10,
                                            argument_value    => 'bit 7');
  sys.dbms_scheduler.enable(name => 'IGSS.JOB_SENDEMAIL_DAILY');
end;
/
